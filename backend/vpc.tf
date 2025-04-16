module "vpc" {
  source              = "../modules/vpc"
  region              = var.region
  vpc_cidr            = var.vpc_cidr
  az_count            = 2
  availability_zones  = []  # Leave empty to auto-select
}

module "security_groups" {
  source     = "../modules/security_groups"
  vpc_id     = module.vpc.vpc_id
  ecs_port   = 8000
  vpc_cidr   = var.vpc_cidr
}

resource "aws_ssm_parameter" "apigw_sg_id" {
  name  = "/apigw-sg/id"
  type  = "String"
  value = module.security_groups.api_gateway_sg_id
}

resource "aws_ssm_parameter" "ecs_sg_id" {
  name  = "/ecs-sg/id"
  type  = "String"
  value = module.security_groups.ecs_security_group_id
}