# -*- coding: utf-8 -*-
"""Order API: Helpers: SNS."""


# Import
import logging
import json
import boto3
from django.conf import settings


# Functions
def get_sns_client():
    """Get SNS client."""
    return boto3.client(
        'sns',
        aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
        aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
        region_name=settings.AWS_REGION
    )


def publish_order_event(order_data):
    """Publish order event to SNS."""
    sns = get_sns_client()

    # Convert order_data to string if it's a dictionary
    message = order_data['order_id']

    params = {
        'TopicArn': settings.SNS_TOPIC_ARN,
        'Message': message,
        'Subject': 'New Order Notification',
        'MessageGroupId': 'orders',
        'MessageDeduplicationId': str(order_data.get('order_id'))
    }

    try:
        response = sns.publish(**params)
        return response
    except Exception as e:
        logging.error(f"Failed to publish SNS message: {str(e)}")
        raise
