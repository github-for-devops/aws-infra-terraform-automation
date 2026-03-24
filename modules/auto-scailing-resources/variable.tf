
variable "alb_sg" {
  type = string
}

variable "s3_access_logs" {
  type = string
  description = "s3 bucket for ALB access logs"
}

variable "vpc_id" {
  type = string
}

variable "app_healthcheck_path" {
  type = string
  description = "Application path for ALB health checks"
  default = "/index.html"
}

variable "health_check_ineterval" {
  type = number
  description = "interval in sec for ALB healthcheck"
}

variable "health_check_timeout" {
  type = number
  description = "timeout in sec for ALB healthcheck"
}

variable "cert_arn" {
  type = string
}

variable "key_name" {
  description = "EC2 Key Pair"
}

variable "ami_id" {
  type = string
  description = "ec2 ami id"
}

variable "user_data" {
  type = string
}

variable "instance_type" {
  type = string
  description = "ec2 instance type"
  default = "t3.medium"
}

variable "kms_ebs_key_id" {
  type = string
}

variable "ebs_volume_size" {
  type = number
}

variable "ec2_sg" {
  type = string
}

variable "alb_subnets" {
  type = set(string)
}

variable "private_subnets" {
  type = set(string)
}

variable "asg_min_size" {
  type = number
}

variable "asg_max_size" {
  type = number
}

variable "asg_desired_size" {
  type = number
}

variable "resource_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cost_center" {
  type = string
}