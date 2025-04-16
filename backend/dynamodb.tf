resource "random_pet" "this" {
  length = 2
}

module "dynamodb_table" {
  source = "../modules/dynamodb"

  name                        = "my-table-${random_pet.this.id}"
  hash_key                    = "order_id"
  #range_key                   = ""
  table_class                 = "STANDARD"
  deletion_protection_enabled = false

  attributes = [
    {
      name = "order_id"
      type = "S"
    },
    {
      name = "customer_name"
      type = "S"
    },
    {
      name = "product_name"
      type = "S"
    },
    {
      name = "quantity"
      type = "N"
    },
    {
      name = "status"
      type = "S"
    }
  ]

# The GSI's are created for querying based on Customer's orders

  global_secondary_indexes = [
    {
      name               = "CustomerNameIndex"
      hash_key           = "customer_name"
      range_key          = "status"
      projection_type    = "INCLUDE"
      non_key_attributes = ["order_id"]

      on_demand_throughput = {
        max_write_request_units = 1
        max_read_request_units  = 1
      }
    },
    {
      name               = "ProductIndex"
      hash_key           = "product_name"
      range_key          = "quantity"
      projection_type    = "INCLUDE"
      non_key_attributes = ["order_id"]

      on_demand_throughput = {
        max_write_request_units = 1
        max_read_request_units  = 1
      }
    }
  ]

  on_demand_throughput = {
    max_read_request_units  = 1
    max_write_request_units = 1
  }

/*
  resource_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAPIGWRoleAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          #"arn:aws:sts::__AWS_ACCOUNT_NUMBER__:assumed-role/<sns-lambda-execution-role/Order-processing-lambda>",
          "arn:aws:iam::__AWS_ACCOUNT_NUMBER__:role/dynamo-access-by-ecs"
        ]
      },
        "Action": [
				"dynamodb:BatchGetItem",
				"dynamodb:DescribeTable",
				"dynamodb:GetItem",
				"dynamodb:Query",
				"dynamodb:Scan",
				"dynamodb:PutItem",
				"dynamodb:UpdateItem",
				"dynamodb:UpdateTable"
      ],
      "Resource": "__DYNAMODB_TABLE_ARN__"
    }
  ]
}
POLICY

  tags = {
    Terraform   = "true"
    Environment = "staging"
  }

*/

}


