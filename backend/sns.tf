module "sns_order_completed" {
  source      = "../modules/sns"
  name        = "order-completed"
  fifo_topic  = false
  tags        = var.sns_tags
}

module "sns_fifo" {
  source                      = "../modules/sns"
  name                        = "order-events"
  fifo_topic                  = true
  content_based_deduplication = true
  tags                        = var.sns_tags
}

resource "aws_ssm_parameter" "sns_topic_arn" {
  name  = "/sns/topic_arn"
  type  = "String"
  value = module.sns_fifo.sns_topic_arn
}