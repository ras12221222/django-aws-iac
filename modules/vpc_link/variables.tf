variable "subnet_ids" {
  description = "Private subnet IDs for VPC link"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group to associate with the VPC Link"
  type        = string
}
