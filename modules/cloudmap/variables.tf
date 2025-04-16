variable "namespace_name" {
  description = "Name of the private DNS namespace"
  type        = string
  default     = "internal"
}

variable "vpc_id" {
  description = "VPC ID to associate the namespace"
  type        = string
}

variable "service_name" {
  description = "Service name to register (e.g., django)"
  type        = string
  default     = "django"
}
