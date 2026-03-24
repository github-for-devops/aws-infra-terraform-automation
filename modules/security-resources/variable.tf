variable "access_log_bucket_name" {
  type = string
  description = "ALB accesss logs s3 bucket name"
}

variable "kms_deletion_window_in_days" {
  type = number
  description = "number of day to keep kms key before deletion"
}

variable "domain_name" {
  type = string
}

variable "vpc_id" {
  type = string
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