resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.namespace_name
  description = "Private namespace for ECS service discovery"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "this" {
  name = var.service_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id

    # API gateway use the SRV record to resolve the ECS service
    dns_records {
      type = "SRV"
      ttl  = 10
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
