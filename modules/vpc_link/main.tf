resource "aws_apigatewayv2_vpc_link" "this" {
  name              = "django-vpc-link"
  security_group_ids = [var.security_group_id]
  subnet_ids         = var.subnet_ids
}
