# -*- coding: utf-8 -*-
"""Order API: Models."""


# Import
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from .serializers import OrderSerializer, OrderRetrieveSerializer
from .helpers_dynamodb import create_order_in_dynamodb, get_order_from_dynamodb
from .helpers_sns import publish_order_event
import uuid


# Classes
class OrderCreateView(APIView):
    def post(self, request):
        serializer = OrderSerializer(data=request.data)
        if serializer.is_valid():
            order_data = serializer.validated_data
            order_data['order_id'] = str(uuid.uuid4())
            order_data['status'] = 'Pending'  # Default status

            dynamo_response = create_order_in_dynamodb(order_data)

            # Publish event to SNS
            sns_response = publish_order_event(order_data)

            return Response({
                'message': 'Order created successfully',
                'order': order_data,
                'dynamo_response': dynamo_response,
                'sns_response': sns_response
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class OrderRetrieveView(APIView):
    def get(self, request, order_id):
        order = get_order_from_dynamodb(str(order_id))
        if not order:
            return Response({'message': 'Order not found'}, status=status.HTTP_404_NOT_FOUND)

        serializer = OrderRetrieveSerializer(data=order)
        if serializer.is_valid():
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
