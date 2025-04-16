resource "aws_sns_topic" "sns_topic" {
  name                        = "${var.name}${var.fifo_topic ? ".fifo" : ""}"
  fifo_topic                  = var.fifo_topic
  display_name                = var.display_name
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null
  delivery_policy             = var.delivery_policy
  tags                        = var.tags
}
