##########################
# Global Configuration
##########################

# Match it to tfvars in backend folder
region = "us-east-1"
az_count  = 2

# This image URI can be overridden by GitHub Actions
container_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-django-app:latest"


##########################
# ECS Service Settings
##########################

ecs_port = 8000
cpu      = 256
memory   = 512

##########################
# Cloud Map (Service Discovery)
##########################

cloudmap_namespace_name = "internal"
cloudmap_service_name   = "django"
