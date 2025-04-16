variable "vpc_id" {
  description = "VPC for ECS service"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for Fargate tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group to attach to ECS service"
  type        = string
}

variable "cloudmap_namespace_id" {
  description = "Cloud Map namespace ID"
  type        = string
}

variable "cloudmap_service_arn" {
  description = "Cloud Map service ARN"
  type        = string
}

variable "container_image" {
  description = "Container image URI (e.g. from ECR)"
  type        = string
}

variable "container_port" {
  description = "Port the container exposes"
  type        = number
  default     = 8000
}

variable "log_group_name" {
  description = "Name of CloudWatch log group"
  type        = string
  default     = "/ecs/django"
}

variable "service_name" {
  description = "ECS Service name"
  type        = string
  default     = "django"
}

variable "cpu" {
  type        = number
  default     = 256
}

variable "memory" {
  type        = number
  default     = 512
}

variable "environment_variables" {
  description = "List of static environment variables to pass to the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "cloudwatch_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
  
}

variable "iam_role" {
  description = "IAM role for ECS task execution"
  type        = string
  default     = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
  
}