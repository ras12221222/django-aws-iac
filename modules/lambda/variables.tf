#############################
# Lambda Configuration
#############################

variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
  default     = "main.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "python3.12"
}

variable "timeout" {
  description = "Time in seconds the function can run before timing out"
  type        = number
  default     = 900
}

variable "memory_size" {
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  default     = 128
}

variable "lambda_package_path" {
  description = "Path to the zipped Lambda deployment package"
  type        = string
}

#############################
# IAM & Permissions
#############################

variable "lambda_role_arn" {
  description = "IAM Role ARN that the Lambda will assume"
  type        = string
}


#############################
# Environment Variables
#############################

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

#############################
# Tags
#############################

variable "tags" {
  description = "Tags to apply to Lambda resources"
  type        = map(string)
  default     = {}
}
