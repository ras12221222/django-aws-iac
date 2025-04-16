##########################
# Global Configuration
##########################

region = "us-east-1"

##########################
# VPC Settings
##########################

vpc_cidr             = "10.100.0.0/16"
az_count             = 2
availability_zones   = []  # Leave empty to auto-select based on az_count

##########################
# Lambda Settings
##########################
function_name = "Order-processing-lambda"
sqs_batch_size = 5
