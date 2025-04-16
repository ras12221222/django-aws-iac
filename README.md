# Project description

## Serverless Event-Driven Order Processing System

### Scenario

You are developing a **serverless event-driven order processing system** for an e-commerce platform. The system consists of:

1. A **Django API** to create and retrieve orders.
2. An **AWS Lambda** function to process orders asynchronously.
3. A **DynamoDB** table to store order details.
4. **SNS & SQS** for event-driven notifications.
5. A **Dockerized environment** for the Django API, running through **ECS**.

---

### Requirements

#### 1. Django REST API (Order Management)

Develop a Django REST API with the following endpoints:

- `POST /orders/` → Create a new order (stores in DynamoDB & publishes an event to SNS)
- `GET /orders/{order_id}/` → Retrieve order details from DynamoDB

**Order fields:**

- `order_id` (UUID)
- `customer_name`
- `product_name`
- `quantity`
- `status` (Pending, Processing, Completed)

---

#### 2. AWS Lambda for Order Processing

The Lambda function should be triggered by an **SQS queue** (which is subscribed to an **SNS topic**). It should:

- Retrieve order details from DynamoDB
- Simulate processing (e.g., sleep for a few seconds)
- Update the order status to `"Completed"` in DynamoDB
- Publish a completion event to another SNS topic

##### Additional Lambda Features:

###### --> Batch Processing with SQS Visibility Timeout Handling

- Process orders in batches (e.g., 5 at a time) from the SQS queue
- Ensure failed messages are retried properly
- Handle SQS visibility timeout to prevent premature message deletion

###### --> Order Processing Simulation with External API Calls

- Call two external APIs (e.g., a fake payment gateway and an inventory system)
- Simulate real-world API failures with a **20% random failure rate**
- Retry failed calls with **exponential backoff** before marking an order as "Failed"

###### --> Distributed Transaction Handling

- Only update DynamoDB if:
    - The payment API confirms success
    - The inventory API confirms stock availability
- If any step fails:
    - Roll back changes
    - Publish an event to a **Dead Letter Queue (DLQ)**

    ---

#### 3. AWS SNS & SQS for Event-Driven Notifications

- Create an SNS topic: `order-events` for new order creation events
- Subscribe an SQS queue: `order-processing-queue` to the SNS topic
- Lambda will process messages from this queue
- A second SNS topic: `order-completed` should receive order completion events

---

#### 4. Dockerization

- Create a `Dockerfile` for the Django API
- Create an **ECS Task Definition** to run the Docker image

---

#### 5. Deployment

- Set up a **GitHub Actions** workflow:
  - Build and push the Django API Docker image to **Amazon ECR**
- Configure **API Gateway** to invoke the Django API (instead of using an ECS Load Balancer)

---

### Deliverables

1. **Code Repository (GitHub)** with:
    - Django API (orders app) and GitHub Actions workflow
    - Lambda function code
    - ECR configuration

2. **README** with setup instructions

3. **Infrastructure as Code** (using either AWS Python SDK, Terraform, or CloudFormation):
    - Automate provisioning of:
      - SQS, SNS, Lambda
      - Triggers, ECS, DynamoDB
      - API Gateway, etc.

---


## Setup Instructions.

The project code consists of the following folder structure

```bash
├── Dockerfile
├── README.md
├── .gitignore
├── .dockerignore
├── .github			// Github Actions
├── backend			// DynamoDB, SNS, SQS, Lambda, VPC, SG, IAM, SSM
├── frontend		// ECS, ECR, APIGW, CloudMap, VPC PrivateLink
├── modules			// Custom terraform modules
├── order_api		// Django OrderApi Application
└── requirements.txt
```
### Step 1: Prepare your environment
- Create a new repository in Github. ( https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository )
- Add below secrets (key/name = value pairs) to your repository. (https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository)

```bash
AWS_ACCESS_KEY_ID = <AWS Account Key ID>
AWS_SECRET_ACCESS_KEY = <AWS Account Secret key>
AWS_REGION = <AWS Region of your choice> 
```

- Clone this repository to your local folder. (https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository)

```bash
git clone https://github.com/ras12221222/django-aws-iac.git 
```

- Initialize git in your local folder and push to remote repository. This should trigger Github Actions to create a docker image and upload it to ECR.

```bash
git init
git remote add origin https://github.com/your-remote-github-repo.git
git pull origin main
git add .
git commit -m 0.0.1
git push --set-upstream origin main  
```

- Install Terraform and AWS CLI. Skip the steps below is already installed.
    - Terraform (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
    - AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Step 2: Modify .tfvars file to match the AWS region used in Step 1 for Github Actions.

- In files /frontend/terraform.tfvars and /backend/terraform.tfvars modify "region" to match your AWS region. The code is set to deploy it to us-west-2.

```bash
    region = "us-west-2"    // Match to region set in Github actions
```

### Step 3: Deploy Backend Infrastructure.

```bash
# Ensure you are in /backend folder

terraform init
terraform plan
terraform apply // Enter 'yes' when prompted.
```

### Step 4: Deploy Frontend Infrastructure.

```bash
# Ensure you are in /frontend folder

terraform init
terraform plan
terraform apply // Enter 'yes' when prompted.
```

### Step 5: Testing.
- If the above steps were executed without errors you should have the API gateway endpoint similar to the output below:

```bash
http_api_endpoint = "https://a9w59eo3f1.execute-api.us-west-2.amazonaws.com"
```
- We will use the API gateway endpoint to test the orders API flow

```bash
curl -X POST https://a9w59eo3f1.execute-api.us-west-2.amazonaws.com/orders/ \
-H "Content-Type: application/json" \
-d '{
    "customer_name": "test customer 1",
    "product_name": "INE CCIE Bootcamp",
    "quantity": 1
}'
```
- If the API is executed without any errors you will see a confirmation similar to one below:

```json
{
  "message": "Order created successfully",
  "order": {
    "customer_name": "test customer 1",
    "product_name": "INE CCIE Bootcamp",
    "quantity": 1,
    "order_id": "8947f230-53f2-436a-85dc-333f0e41e766",
    "status": "Pending"
  },
  "dynamo_response": {
    "ResponseMetadata": {
      "RequestId": "TPL2TAG4ELVC8R3RJMT9DM897FVV4KQNSO5AEMVJF66Q9ASUAAJG",
      "HTTPStatusCode": 200,
      "HTTPHeaders": {
        "server": "Server",
        "date": "Tue, 15 Apr 2025 08:23:11 GMT",
        "content-type": "application/x-amz-json-1.0",
        "content-length": "2",
        "connection": "keep-alive",
        "x-amzn-requestid": "TPL2TAG4ELVC8R3RJMT9DM897FVV4KQNSO5AEMVJF66Q9ASUAAJG",
        "x-amz-crc32": "2745614147"
      },
      "RetryAttempts": 0
    }
  },
  "sns_response": {
    "MessageId": "58adbd4e-350b-5fcf-8d5b-dd362ca42b4c",
    "SequenceNumber": "10000000000000030000",
    "ResponseMetadata": {
      "RequestId": "d64c60f2-4ea7-5328-8dc2-008a570857ab",
      "HTTPStatusCode": 200,
      "HTTPHeaders": {
        "x-amzn-requestid": "d64c60f2-4ea7-5328-8dc2-008a570857ab",
        "date": "Tue, 15 Apr 2025 08:23:11 GMT",
        "content-type": "text/xml",
        "content-length": "352",
        "connection": "keep-alive"
      },
      "RetryAttempts": 0
    }
  }
}
```

- Next we will test retrival of the placed order.

```bash
curl -X GET https://a9w59eo3f1.execute-api.us-west-2.amazonaws.com/orders/8947f230-53f2-436a-85dc-333f0e41e766/
```

- If the API is executed without any errors you will see a confirmation similar to one below:

```json
{
  "order_id": "8947f230-53f2-436a-85dc-333f0e41e766",
  "customer_name": "test customer 1",
  "product_name": "INE CCIE Bootcamp",
  "quantity": 1,
  "status": "Completed"
}
```


