variable "alb_subnets" {
  type = set(string)
  description = "public subnet ids for ALB"
}

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
  default = 30
}

variable "health_check_timeout" {
  type = number
  description = "timeout in sec for ALB healthcheck"
  default = 5
}

variable "cert_arn" {
  type = string
}

variable "key_name" {
  description = "EC2 Key Pair"
  default     = null
}

variable "ami_id" {
  type = string
  description = "ec2 ami id"
  default = ""
}

variable "instance_type" {
  type = string
  description = "ec2 instance type"
  default = "t3.medium"
}

variable "user_data" {
  type = string
  description = "ec2 user data script"
}

variable "kms_ebs_key_id" {
  type = string
}

variable "ebs_volume_size" {
  type = number
  default = 8
}

variable "ec2_sg" {
  type = string
}

variable "private_subnets" {
  type = set(string)
  description = "private subnets ids"
}
