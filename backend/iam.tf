data "aws_iam_policy_document" "ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "ecs_policy" {
  statement {
    sid       = "AllowEcsLambdaDynamoAccess"
    effect    = "Allow"
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:Query", "dynamodb:UpdateItem", "dynamodb:DescribeTable","dynamodb:Scan", "dynamodb:UpdateTable"]
    resources = [module.dynamodb_table.dynamodb_table_arn]
  }
  statement {
    sid     = "AllowECSToPublishToSNS"
    effect  = "Allow"
    actions = ["sns:Publish"]
    resources = [
      "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }
  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/*"
    ]
  }
  statement {
    sid    = "AllowECRAccess"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "AllowSSMAccess"
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
      "ecs:ExecuteCommand",
      "ssm:StartSession",
      "ssm:GetConnectionStatus",
      "ssm:DescribeSessions",
      "logs:DescribeLogGroups",
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    sid       = "AllowDynamoDBAccess"
    actions   = [
      "dynamodb:BatchGetItem",
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:UpdateTable"
    ]
    resources = [module.dynamodb_table.dynamodb_table_arn]
  }

  statement {
    sid     = "AllowSQSAccess"
    actions = ["sqs:SendMessage", "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
    resources = [
      "arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

  statement {
    sid     = "AllowSNSAccess"
    actions = ["sns:Publish"]
    resources = [
      "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:*"
    ]
  }

    statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
    ]
  }

}


module "ecs_dynamo_role" {
  source             = "../modules/iam/assume_role"
  role_name          = "ecs-multi-service-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role.json
  inline_policy_json = {
    ecs_policy = data.aws_iam_policy_document.ecs_policy.json
  }
}

module "lambda_dynamo_sqs_sns_role" {
  source             = "../modules/iam/assume_role"
  role_name          = "lambda-multi-service-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  inline_policy_json = {
    lambda_policy = data.aws_iam_policy_document.lambda_policy.json
  }
}
