
variable "alert_email" {
  type = string
  description = "email for alert notification"
}

variable "target_group_arn_suffix" {
  type = string
}

variable "load_balancer_arn_suffix" {
  type = string
}

variable "asg_name" {
  type = string
}

