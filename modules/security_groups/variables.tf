variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ecs_port" {
  description = "Port for ECS service"
  type        = number
  default     = 8000
}

variable "vpc_cidr" {
  description = "VPC CIDR range"
  type        = string
}
