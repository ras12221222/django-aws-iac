module "order-processing-queue_dlq" {
  source = "../modules/sqs"
  name   = "order-processing-queue-dlq"
  fifo   = true
  tags   = var.sqs_tags
}

module "fifo_sqs" {
  source                        = "../modules/sqs"
  name                          = "order-processing-queue"
  fifo                          = true
  content_based_deduplication   = true
  dlq_enabled                   = true
  dlq_queue_arn                 = module.order-processing-queue_dlq.queue_arn
  subscribe_to_sns              = true
  sns_topic_arn                 = module.sns_fifo.sns_topic_arn
  enable_lambda_trigger         = true
  lambda_function_name          = module.lambda_function.lambda_function_arn
  lambda_batch_size             = var.sqs_batch_size
  tags                          = var.sqs_tags
}


