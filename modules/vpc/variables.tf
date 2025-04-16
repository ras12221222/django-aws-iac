variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "List of AZs to use. If empty, AZs will be selected automatically."
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Whether to create a NAT gateway"
  default     = true
}