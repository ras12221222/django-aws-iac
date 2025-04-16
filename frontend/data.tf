locals {
  subnet_ssm_paths = [
    for i in range(var.az_count) : "/vpc/private_subnets/${i}"
  ]
}

data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "apigw_sg_id" {
  name = "/apigw-sg/id"
}
data "aws_ssm_parameter" "ecs_sg_id" {
  name = "/ecs-sg/id"
}
data "aws_ssm_parameter" "vpc_id" {
  name = "/vpc/id"
}

data "aws_ssm_parameter" "dynamodb_orders_table" {
  name = "/dynamodb/table_name"
}

data "aws_ssm_parameter" "sns_topic_arn" {
  name = "/sns/topic_arn"
}

data "aws_ssm_parameter" "private_subnets" {
  for_each = toset(local.subnet_ssm_paths)
  name     = each.value
}

data "aws_ssm_parameter" "container_image" {
  name = "/order_api/image_uri"
}

data "aws_ssm_parameter" "ecs_task_role_arn" {
  name = "/iam/ecs-multi-service-role"
}
