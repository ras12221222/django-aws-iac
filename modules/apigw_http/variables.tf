variable "vpc_link_id" {
  description = "VPC Link ID for API Gateway to connect to ECS"
  type        = string
}


variable "container_port" {
  description = "Port the ECS container is listening on"
  type        = number
  default     = 8000
}

variable "api_name" {
  description = "Name of the HTTP API Gateway"
  type        = string
  default     = "django-http-api"
}

variable "cloudmap_service_arn" {
  description = "The ARN of the CloudMap service for ECS service discovery"
  type        = string
}

variable "route_keys" {
  description = "List of route keys for the API Gateway"
  type        = map(string)
  default     = {
    "GET /" = "GET /"
    "POST /" = "POST /"
  }
}