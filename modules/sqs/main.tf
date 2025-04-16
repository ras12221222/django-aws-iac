resource "aws_sqs_queue" "main" {
  name                        = "${var.name}${var.fifo ? ".fifo" : ""}"
  fifo_queue                  = var.fifo
  content_based_deduplication = var.fifo ? var.content_based_deduplication : null

  delay_seconds               = var.delay_seconds
  max_message_size            = var.max_message_size
  message_retention_seconds   = var.message_retention_seconds
  receive_wait_time_seconds   = var.receive_wait_time_seconds
  visibility_timeout_seconds  = var.visibility_timeout_seconds

  redrive_policy = var.dlq_enabled ? jsonencode({
    deadLetterTargetArn = var.dlq_queue_arn
    maxReceiveCount     = var.dlq_max_receive_count
  }) : null

  kms_master_key_id                  = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds

  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "lambda_trigger" {
  count = var.enable_lambda_trigger ? 1 : 0

  event_source_arn                          = aws_sqs_queue.main.arn
  function_name                             = var.lambda_function_name
  enabled                                   = var.lambda_trigger_enabled
  batch_size                                = var.lambda_batch_size
  maximum_batching_window_in_seconds        = var.lambda_max_batching_window
  function_response_types                   = ["ReportBatchItemFailures"]

  depends_on = [aws_sqs_queue.main]
}

resource "aws_sns_topic_subscription" "sns_to_sqs" {
  for_each = var.subscribe_to_sns ? toset(["sns"]) : []

  topic_arn            = var.sns_topic_arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.main.arn
  raw_message_delivery = true

  depends_on = [aws_sqs_queue.main]
}

data "aws_iam_policy_document" "sns_to_sqs" {
  for_each = var.subscribe_to_sns ? toset(["sns"]) : []

  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.main.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [var.sns_topic_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "allow_sns" {
  for_each = var.subscribe_to_sns ? toset(["sns"]) : []

  queue_url = aws_sqs_queue.main.id
  policy    = data.aws_iam_policy_document.sns_to_sqs[each.key].json

  depends_on = [aws_sqs_queue.main]
}