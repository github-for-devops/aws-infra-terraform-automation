variable "vpc_cidr" {
  type = string
  description = "vpc cidr"
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
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