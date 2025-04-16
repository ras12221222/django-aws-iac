# -*- coding: utf-8 -*-
"""Order API: Helpers: DynamoDB."""


# Import
import boto3
from boto3.dynamodb.conditions import Key
from django.conf import settings
import logging


# Functions
def get_dynamodb_resource():
    """Get DynamoDB resource."""
    return boto3.resource(
        'dynamodb',
        aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
        region_name=settings.AWS_REGION
    )


def create_order_in_dynamodb(order_data):
    """Create order in DynamoDB."""
    dynamodb = get_dynamodb_resource()
    table = dynamodb.Table(settings.DYNAMODB_ORDERS_TABLE)

    # Ensure order_id is string (UUID)
    order_data['order_id'] = str(order_data['order_id'])

    response = table.put_item(
        Item=order_data
    )
    return response


def get_order_from_dynamodb(order_id):
    """Get order from DynamoDB."""
    try:
        dynamodb = get_dynamodb_resource()
        table = dynamodb.Table(settings.DYNAMODB_ORDERS_TABLE)

        response = table.get_item(
            Key={'order_id': str(order_id)}
        )

        if 'Item' not in response:
            return None
        return response['Item']

    except Exception as e:
        logging.error(f"Error fetching order {order_id}: {str(e)}")
        raise
