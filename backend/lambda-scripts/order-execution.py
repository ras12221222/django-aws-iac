import json
import os
import random
import time
import boto3
import logging
#import requests
import uuid
from botocore.exceptions import ClientError

# AWS clients
dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
sqs = boto3.client('sqs')

# Environment variables
ORDERS_TABLE = os.environ.get("ORDERS_TABLE","my-table-central-tuna")
COMPLETION_SNS_TOPIC_ARN = os.environ.get("COMPLETION_SNS_TOPIC_ARN","arn:aws:sns:us-west-1:123456789012:test-order-completed")
#change to dedicated DLQ 
#DLQ_SQS_URL = os.environ.get("DLQ_SQS_URL","https://sqs.us-west-1.amazonaws.com/123456789012/Lambda-DLQ")
PAYMENT_API_URL = os.environ.get("PAYMENT_API_URL", "https://fake-payment.example.com")
INVENTORY_API_URL = os.environ.get("INVENTORY_API_URL", "https://fake-inventory.example.com")

# Constants
MAX_RETRIES = 3
BACKOFF_FACTOR = 2
#FAILURE_RATE = 0.2 
SUCCESS_RATE = 0.8  # 80% simulated success

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Entry point: triggered by SQS batch event.
    """
    batch_item_failures = []

    for record in event['Records']:
        try:
            order_id = record['body']
            logger.info(f"Processing order: {order_id}")
            process_order(order_id)
        except Exception as e:
            logger.error(f"Failed to process order {record['body']}: {str(e)}")
            # publish_to_dlq(record['body'], str(e))
            # Raising error so SQS will retry based on redrive policy
            batch_item_failures.append({"itemIdentifier": record["messageId"]})
            return {"batchItemFailures": batch_item_failures}

def update_order_status(order_id, status):
    """
    Updates the order status in DynamoDB.
    """
    try:
        table = dynamodb.Table(ORDERS_TABLE)
        table.update_item(
            Key={'order_id': order_id},
            UpdateExpression="SET #st = :s",
            ExpressionAttributeNames={"#st": "status"},
            ExpressionAttributeValues={":s": status}
        )
        logger.info(f"Order {order_id} status updated to {status}")
    except Exception as e:
        logger.error(f"Failed to update status for order {order_id} to {status}: {str(e)}")

def process_order(order_id):
    table = dynamodb.Table(ORDERS_TABLE)

    # Step 1: Retrieve order
    order = table.get_item(Key={'order_id': order_id}).get('Item')
    if not order:
        raise Exception(f"Order {order_id} not found.")
    
    current_status = order.get("status", "").lower()

    if current_status != "pending":
        logger.info(f"Order {order_id} has status '{current_status}' — skipping processing.")
        return
    
    # Step 2: Update order to Processing
    update_order_status(order_id, "Processing")
    logger.info(f"Order {order_id} is Processing ......")

    # Step 3: Simulate processing delay
    time.sleep(random.randint(2, 5))

    # Step 4: Call payment API (simulated)
    if not call_with_retry(PAYMENT_API_URL, order):
        update_order_status(order_id, "Pending")
        raise Exception("Payment processing failed.")

    # Step 5: Call inventory API (simulated)
    if not call_with_retry(INVENTORY_API_URL, order):
        update_order_status(order_id, "Pending")
        raise Exception("Inventory check failed.")

    # Step 6: Update status to "Completed"
    update_order_status(order_id, "Completed")
    logger.info(f"---> Order {order_id} marked as Completed!!")

    # Step 7: Publish completion event
    sns.publish(
        TopicArn=COMPLETION_SNS_TOPIC_ARN,
        Message=json.dumps({"order_id": order_id, "status": "Completed"}),
        Subject="Order {order_id} Completed"
    )

"""
def call_with_retry(url, order, max_retries=MAX_RETRIES):
    retry_count = 0
    while retry_count < max_retries:
        try:
            # Simulated failure
            if random.random() < FAILURE_RATE:
                raise Exception("Simulated API failure")

            response = requests.post(url, json=order, timeout=3)
            if response.status_code == 200:
                return True
            else:
                logger.warning(f"Non-200 response from {url}: {response.status_code}")
        except Exception as e:
            wait_time = BACKOFF_FACTOR ** retry_count
            logger.warning(f"API call failed ({url}), retry {retry_count + 1}/{max_retries} in {wait_time}s: {str(e)}")
            time.sleep(wait_time)
            retry_count += 1
    return False
"""

def call_with_retry(api_name, order, max_retries=MAX_RETRIES):
    """
    Simulates an API call with retry and backoff.
    Randomized 80% success and 20% failure behavior.
    """
    retry_count = 0
    while retry_count < max_retries:
        try:
            # Simulate API call
            response = simulated_api_call(api_name, order)

            # Check for success response
            if response['status_code'] == 200:
                return True
            else:
                logger.warning(f"{api_name} API responded with {response['status_code']}")
        except Exception as e:
            logger.warning(f"{api_name} API error: {str(e)}")

        # Backoff before retry
        wait_time = BACKOFF_FACTOR ** retry_count
        time.sleep(wait_time)
        retry_count += 1

    return False


def simulated_api_call(api_name, order):
    """
    Simulates an API call for either 'payment' or 'inventory'.
    Has an 80% chance of success and a 20% chance of failure.
    """
    success = random.random() < SUCCESS_RATE  # 80% success rate
    if success:
        logger.info(f"{api_name} API simulated success for order {order['order_id']}")
        return {'status_code': 200, 'body': 'OK'}
    else:
        logger.warning(f"{api_name} API simulated failure for order {order['order_id']}")
        return {'status_code': 500, 'body': 'Simulated error'}


"""
def publish_to_dlq(order_id, error_message):
    message = {
        "order_id": order_id,
        "error": error_message,
        "failure_id": str(uuid.uuid4()),
        "timestamp": int(time.time())
    }
    try:
        sqs.send_message(
            QueueUrl=DLQ_SQS_URL,
            MessageBody=json.dumps(message)
        )
        logger.info(f"Published order {order_id} failure to SQS DLQ")
    except ClientError as e:
        logger.error(f"Failed to send to DLQ: {str(e)}")
"""