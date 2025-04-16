output "order_completed_sns_topic_arn" {
  value = module.sns_order_completed.sns_topic_arn
}

output "sns_fifo_topic_arn" {
  value = module.sns_fifo.sns_topic_arn
}
