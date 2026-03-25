variable "region" {
  default = "ap-south-1"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "vpc cidr"
}

variable "azs" {
  description = "List of Availability Zones"
  default = [ "ap-south-1a", "ap-south-1b" ]
  type        = list(string)
}

variable "access_log_bucket_name" {
  type = string
  description = "S3 bucket name for alb access logs"
}

variable "kms_deletion_window_in_days" {
    type = number
    default = 7
    description = "number of day to keep kms key before deletion"
}

variable "domain_name" {
    type = string
    description = "valid domain name for application"
}

variable "app_healthcheck_path" {
  type = string
  default = "/index.html"
  description = "Application path for ALB health checks"
}

variable "health_check_ineterval" {
  type = number
  default = 30
  description = "interval in sec for ALB healthcheck"
}

variable "health_check_timeout" {
  type = number
  default = 5
  description = "timeout in sec for ALB healthcheck"
}

variable "key_name" {
  type = string
  description = "EC2 Key Pair Name"
}

variable "ami_id" {
  type = string
  description = "ec2 ami id"
}

variable "instance_type" {
  type = string
  default = "m6a.large"
  description = "ec2 instance type"
}

variable "ebs_volume_size" {
  type = number
  default = 8
  description = "ebs volume size in GB"
}

variable "asg_min_size" {
  type = number
  default = 2
  description = "min value of ec2 to be running"
}

variable "asg_max_size" {
  type = number
  default = 4
  description = "max value of ec2 to be running"
}

variable "asg_desired_size" {
  type = number
  default = 2
  description = "desired value of ec2 to be running"
}

variable "alert_email" {
  type = string
  description = "email for alert notification"
}

variable "resource_name" {
  type = string
  default = "prodapp"
  description = "tag value for resource name"
}

variable "environment" {
  type = string
  default = "prod"
  description = "tag value for environment"
}

variable "cost_center" {
  type = string
  default = "webapp"
  description = "tag value for cost center"
}
