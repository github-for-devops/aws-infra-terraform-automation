output "tg_arn" { 
    value = aws_lb_target_group.ec2_tg.arn 
}

output "alb_dns" { 
    value = aws_lb.application_alb.dns_name 
}

output "asg_name" {
  value = aws_autoscaling_group.ec2_asg.name
}

output "tg_arn_suffix" {
  value = aws_lb_target_group.ec2_tg.arn_suffix
}

output "lb_arn_suffix" {
  value = aws_lb.application_alb.arn_suffix
}