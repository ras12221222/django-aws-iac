resource "aws_security_group" "ecs" {
  name        = "ecs-sg"
  vpc_id      = var.vpc_id
  description = "Allow internal app traffic"
}

resource "aws_security_group_rule" "ecs_ingress" {
  type              = "ingress"
  from_port         = var.ecs_port
  to_port           = var.ecs_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group_rule" "ecs_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs.id
}

resource "aws_security_group" "apigw" {
  name        = "apigw-sg"
  vpc_id      = var.vpc_id
  description = "API Gateway to ECS"
}

resource "aws_security_group_rule" "apigw_ingress" {
  type              = "ingress"
  from_port         = var.ecs_port
  to_port           = var.ecs_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.apigw.id
}

resource "aws_security_group_rule" "apigw_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.apigw.id
}

