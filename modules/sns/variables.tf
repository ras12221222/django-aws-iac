variable "name" {
  description = "Base name for the SNS topic"
  type        = string
}

variable "fifo_topic" {
  description = "Whether the topic is FIFO"
  type        = bool
  default     = false
}

variable "display_name" {
  description = "Optional display name for the SNS topic"
  type        = string
  default     = ""
}

variable "content_based_deduplication" {
  description = "Only for FIFO topics"
  type        = bool
  default     = false

  validation {
    condition     = !(var.content_based_deduplication && !var.fifo_topic)
    error_message = "content_based_deduplication can only be true if fifo_topic is true."
  }
}

variable "delivery_policy" {
  description = "SNS delivery policy as a JSON string"
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the SNS topic"
  default     = {}
}

# Optional SQS Subscription
variable "subscribe_to_sqs" {
  description = "Subscribe an SQS queue to this topic"
  type        = bool
  default     = false
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue to subscribe (if enabled)"
  type        = string
  default     = ""
}

variable "sqs_queue_url" {
  type    = string
  default = ""
}

