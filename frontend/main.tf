
module "cloudmap" {
  source  = "../modules/cloudmap"
  vpc_id     = data.aws_ssm_parameter.vpc_id.value

}

module "ecs" {
  source                 = "../modules/ecs"
  # Will be overridden in CI/CD via GitHub Actions
  container_image        = data.aws_ssm_parameter.container_image.value
  vpc_id                 = data.aws_ssm_parameter.vpc_id.value
  private_subnet_ids     = [
    for subnet in data.aws_ssm_parameter.private_subnets : subnet.value
  ]
  security_group_id      = data.aws_ssm_parameter.ecs_sg_id.value
  cloudmap_namespace_id  = module.cloudmap.namespace_id
  cloudmap_service_arn   = module.cloudmap.service_arn
  cloudwatch_region      = var.region
  iam_role               = data.aws_ssm_parameter.ecs_task_role_arn.value
  environment_variables = [
    {
      name  = "DYNAMODB_ORDERS_TABLE"
      value = data.aws_ssm_parameter.dynamodb_orders_table.value
    },
    {
      name  = "SNS_TOPIC_ARN"
      value = data.aws_ssm_parameter.sns_topic_arn.value
    } 
    ]
}

module "vpc_link" {
  source            = "../modules/vpc_link"
  subnet_ids        = [
    for subnet in data.aws_ssm_parameter.private_subnets : subnet.value
  ]
  security_group_id = data.aws_ssm_parameter.apigw_sg_id.value
}

module "apigw_http" {
  source                = "../modules/apigw_http"
  vpc_link_id           = module.vpc_link.vpc_link_id
  cloudmap_service_arn  = module.cloudmap.service_arn
    route_keys = {
    "POST /orders"           = "POST"
    "GET /orders/{order_id}" = "GET"
  }
}
