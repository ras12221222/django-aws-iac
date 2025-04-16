output "queue_url" {
  value = aws_sqs_queue.main.id
}

output "queue_arn" {
  value = aws_sqs_queue.main.arn
}

output "enable_lambda_trigger" {
  value       = var.enable_lambda_trigger
  description = "Whether Lambda trigger is enabled for the SQS queue"
}