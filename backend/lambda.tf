data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/${var.lambda_source_file}"
  output_path = "${path.module}/lambda.zip"
}

module "lambda_function" {
  source              = "../modules/lambda"
  function_name       = var.function_name
  handler             = "order-execution.lambda_handler"
  runtime             = var.runtime
  timeout             = var.timeout
  memory_size         = var.memory_size
  lambda_package_path = data.archive_file.lambda_zip.output_path
  lambda_role_arn     = module.lambda_dynamo_sqs_sns_role.role_arn

  environment_variables = {
        ORDERS_TABLE = module.dynamodb_table.dynamodb_table_name
        COMPLETION_SNS_TOPIC_ARN = module.sns_order_completed.sns_topic_arn
  }
  tags                  = var.lambda_tags
}

