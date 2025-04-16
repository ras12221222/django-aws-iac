variable "role_name" {
  type        = string
  description = "Name of the IAM role"
}

variable "description" {
  type        = string
  default     = ""
  description = "Description of the role"
}

variable "assume_role_policy" {
  type        = string
  description = "Trust relationship (who can assume the role)"
}

variable "inline_policy_json" {
  type        = map(string)
  default     = {}
  description = "Optional inline IAM policy in JSON format"
}

variable "managed_policy_arns" {
  type        = list(string)
  default     = []
  description = "List of managed policy ARNs to attach"
}

variable "tags" {
  type    = map(string)
  default = {}
}
