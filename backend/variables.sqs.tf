variable "sqs_name" {
  type        = string
  description = "Name of the SQS queue"
  default = ""
}

variable "sqs_lambda_function_arn" {
  type        = string
  description = "Lambda function ARN to trigger"
  default = ""
}

variable "sqs_batch_size" {
  type        = number
  default     = 5
}

variable "retention_seconds" {
  type        = number
  default     = 345600
}

variable "dlq_retention_seconds" {
  type        = number
  default     = 1209600
}

variable "max_receive_count" {
  type        = number
  default     = 5
}

variable "sqs_tags" {
  type        = map(string)
  default     = {}
}
variable "subscribe_to_sns" {
  description = "Whether this SQS queue should subscribe to an SNS topic"
  type        = bool
  default     = false
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN to subscribe this queue to"
  type        = string
  default     = ""
}