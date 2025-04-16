# -*- coding: utf-8 -*-
"""Order API serializers."""


# Import
from rest_framework import serializers
from .models import Order


# Classes
class OrderSerializer(serializers.ModelSerializer):
    order_id = serializers.UUIDField(format='hex_verbose', read_only=True)

    class Meta:
        model = Order
        fields = ['order_id', 'customer_name', 'product_name', 'quantity', 'status']


class OrderRetrieveSerializer(serializers.Serializer):
    order_id = serializers.UUIDField()
    customer_name = serializers.CharField()
    product_name = serializers.CharField()
    quantity = serializers.IntegerField()
    status = serializers.CharField()
