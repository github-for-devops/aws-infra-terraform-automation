resource "aws_lb" "application_alb" {
  name   = "application_lb"
  load_balancer_type = "application"
  subnets            = var.alb_subnets
  security_groups    = [var.alb_sg]

  access_logs {
    bucket  = var.s3_access_logs
    enabled = true
  }
  depends_on = [ aws_lb_target_group.ec2_tg ]
  tags = {
      Environment = var.environment
      CostCenter = var.cost_center
  }
}

resource "aws_lb_target_group" "ec2_tg" {
  name    = "application_ec2_tg"
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
  tags = {
      Environment = var.environment
      CostCenter = var.cost_center
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
  tags = {
      Environment = var.environment
      CostCenter = var.cost_center
  }
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
  tags = {
      Environment = var.environment
      CostCenter = var.cost_center
  }
#   depends_on = [ aws_lb.application_alb ]
}

resource "aws_launch_template" "ec2_launch_template" {
  name = "application_ec2_lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name 
   iam_instance_profile {
    name = "application-ec2-profile"
  }
  metadata_options {
    http_tokens = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      encrypted  = true
      kms_key_id = var.kms_ebs_key_id
      volume_size = var.ebs_volume_size
      volume_type = "gp2"
    }
  }

  user_data = base64encode(var.user_data)

  network_interfaces {
    security_groups             = [var.ec2_sg]
    associate_public_ip_address = false
  }
  tags = {
      Environment = var.environment
      CostCenter = var.cost_center
  }
}

resource "aws_autoscaling_group" "ec2_asg" {
  name    = "applcaition-asg"
  min_size = var.asg_min_size
  max_size = var.asg_max_size
  desired_capacity = var.asg_desired_size

  vpc_zone_identifier = var.private_subnets

  launch_template {
    id = aws_launch_template.ec2_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.ec2_tg.arn]
  tag {
    key                 = Name
    value               = "${var.resource_name}-ec2"
    propagate_at_launch = true
  }
  tag {
    key                 = Environment
    value               = var.environment
    propagate_at_launch = true
  }
  tag {
    key                 = CostCenter
    value               = var.cost_center
    propagate_at_launch = true
  }
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

