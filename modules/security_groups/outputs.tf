output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}

output "api_gateway_sg_id" {
  value = aws_security_group.apigw.id
}
