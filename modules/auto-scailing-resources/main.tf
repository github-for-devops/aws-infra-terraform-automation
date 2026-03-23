resource "aws_lb" "application_alb" {
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = [var.alb_sg]

  access_logs {
    bucket  = var.s3_access_logs
    enabled = true
  }
  depends_on = [ aws_lb_target_group.ec2_tg ]
}

resource "aws_lb_target_group" "ec2_tg" {
  vpc_id = var.vpc_id
  port   = 80
  protocol = "HTTP"
  health_check {
    enabled             = true
    path                = var.app_healthcheck_path
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = var.health_check_ineterval
    timeout             = var.health_check_timeout
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.application_alb.arn
  port = 443
  protocol = "HTTPS"
  certificate_arn = var.cert_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.ec2_tg.arn
  }
#   depends_on = [ aws_lb.application_alb ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application_alb.arn
  port = 80

  default_action {
    type = "redirect"
    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
#   depends_on = [ aws_lb.application_alb ]
}

resource "aws_launch_template" "ec2_launch_template" {
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name 

  metadata_options {
    http_tokens = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted  = true
      kms_key_id = var.kms_ebs_key_id
      volume_size = var.ebs_volume_size
    }
  }

  user_data = base64encode(file(var.user_data))

  network_interfaces {
    security_groups             = [var.ec2_sg]
    associate_public_ip_address = false
  }
}

resource "aws_autoscaling_group" "ec2_asg" {
  min_size = 2
  max_size = 4
  desired_capacity = 2

  vpc_zone_identifier = var.private_subnets

  launch_template {
    id = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.ec2_tg.arn]
  depends_on = [ aws_lb_target_group.ec2_tg, aws_launch_template.ec2_launch_template ]
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "cpu-target"
  autoscaling_group_name = aws_autoscaling_group.ec2_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

