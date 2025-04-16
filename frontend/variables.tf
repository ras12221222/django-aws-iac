##########################
# Global Configuration
##########################

variable "region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# overriden by tfvars
variable "az_count" {
  description = "Number of Availability Zones to deploy across"
  type        = number
  default     = 2
}

variable "container_image" {
  description = "Full ECR container image URI with tag (e.g., latest)"
  type        = string
}

##########################
# ECS Configuration
##########################

variable "ecs_port" {
  description = "Port your Django container listens on"
  type        = number
  default     = 8000
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Fargate memory (in MiB)"
  type        = number
  default     = 512
}

##########################
# Cloud Map Configuration
##########################

variable "cloudmap_namespace_name" {
  description = "Private DNS namespace for service discovery"
  type        = string
  default     = "internal"
}

variable "cloudmap_service_name" {
  description = "Name of the service in Cloud Map"
  type        = string
  default     = "django"
}

variable cloudwatch_region {
  description = "AWS region for CloudWatch logs"
  type        = string
  default     = "us-east-1"
}

variable "route_keys" {
  description = "A map of route keys (method and path) to the ECS integration."
  type = map(string)
  default = {}
}

