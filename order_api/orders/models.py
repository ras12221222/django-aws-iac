# -*- coding: utf-8 -*-
"""Order API: Models."""


# Import
from django.db import models
from uuid import uuid4


# Classes
class Order(models.Model):
    ORDER_STATUS_CHOICES = [
        ('Pending', 'Pending'),
        ('Processing', 'Processing'),
        ('Completed', 'Completed'),
    ]

    order_id = models.UUIDField(primary_key=True, default=uuid4, editable=False)
    customer_name = models.CharField(max_length=100)
    product_name = models.CharField(max_length=100)
    quantity = models.PositiveIntegerField()
    status = models.CharField(max_length=20, choices=ORDER_STATUS_CHOICES, default='Pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
