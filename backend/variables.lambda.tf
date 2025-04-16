#############################
# Lambda Function Settings
#############################

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "The entry point of the Lambda function"
  type        = string
  default     = "main.lambda_handler"
}

variable "runtime" {
  description = "Runtime environment for the Lambda function"
  type        = string
  default     = "python3.12"
}

variable "timeout" {
  description = "Function execution timeout in seconds"
  type        = number
  default     = 300
}

variable "memory_size" {
  description = "Amount of memory (in MB) allocated to the Lambda function"
  type        = number
  default     = 128
}

#############################
# IAM & Role Config
#############################

variable "lambda_role_arn" {
  description = "IAM role ARN the Lambda function will assume"
  type        = string
  default     = ""
}


#############################
# Code + Environment Config
#############################

variable "environment_variables" {
  description = "Key-value pairs to inject as Lambda environment variables"
  type        = map(string)
  default     = {}
}

variable "lambda_source_file" {
  description = "Path to the Lambda Python file (e.g. scripts/main.py)"
  type        = string
  default     = "lambda-scripts/order-execution.py"
}

#############################
# Tagging
#############################

variable "lambda_tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
