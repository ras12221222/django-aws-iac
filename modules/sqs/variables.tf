variable "name" {
  description = "Base name for the SQS queue"
  type        = string
}

variable "fifo" {
  description = "Whether the queue is FIFO"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Only applies to FIFO queues"
  type        = bool
  default     = false

  validation {
    condition     = !(var.content_based_deduplication && !var.fifo)
    error_message = "content_based_deduplication can only be true if fifo is true."
  }
}

variable "delay_seconds" {
  type        = number
  default     = 0
}

variable "max_message_size" {
  type        = number
  default     = 262144
}

variable "message_retention_seconds" {
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  type        = number
  default     = 0
}

variable "visibility_timeout_seconds" {
  type        = number
  default     = 500
}

variable "kms_master_key_id" {
  description = "KMS key ID for encryption. Null for AWS managed key."
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  type        = number
  default     = 300
}

# DLQ support
variable "dlq_enabled" {
  description = "Enable DLQ"
  type        = bool
  default     = false
}

variable "dlq_queue_arn" {
  description = "ARN of the DLQ"
  type        = string
  default     = ""
}

variable "dlq_max_receive_count" {
  type        = number
  default     = 10
}

# Lambda trigger support
variable "enable_lambda_trigger" {
  description = "Enable Lambda trigger"
  type        = bool
  default     = false
}

variable "lambda_function_name" {
  description = "Lambda function ARN or name"
  type        = string
  default     = ""
}

variable "lambda_trigger_enabled" {
  type    = bool
  default = true
}

variable "lambda_batch_size" {
  type    = number
  default = 10
}

variable "lambda_max_batching_window" {
  type    = number
  default = 0
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "subscribe_to_sns" {
  type        = bool
  default     = false
  description = "Whether to subscribe this queue to an SNS topic"
}

variable "sns_topic_arn" {
  type        = string
  default     = ""
  description = "SNS topic ARN to subscribe to"
}