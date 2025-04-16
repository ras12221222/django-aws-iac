resource "aws_cloudwatch_log_group" "ecs" {
  name              = var.log_group_name
  retention_in_days = 7
}

resource "aws_ecs_cluster" "this" {
  name = "django-cluster"
}

resource "aws_ecs_task_definition" "django" {
  family                   = "django-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.iam_role
  task_role_arn            = var.iam_role

  container_definitions = jsonencode([
    {
      name      = "django"
      image     = var.container_image
      essential = true
      portMappings = [{
        containerPort = var.container_port
        protocol      = "tcp"
      }]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name,
          awslogs-region        = var.cloudwatch_region,
          awslogs-stream-prefix = "django"
        }
      }
      environment = var.environment_variables
    }
  ])
}

resource "aws_ecs_service" "django" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.django.arn
  enable_execute_command = true
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = var.cloudmap_service_arn
    port = var.container_port
  }
}

/*
# Minimal IAM role for Fargate execution
resource "aws_iam_role" "ecs_task_exec" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
*/