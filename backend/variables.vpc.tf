##########################
# Global Configuration
##########################

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}


##########################
# VPC Configuration
##########################

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of Availability Zones to deploy across"
  type        = number
  default     = 2
}

variable "availability_zones" {
  description = "List of Availability Zones. If empty, will be generated dynamically"
  type        = list(string)
  default     = []
}

