FROM python:bookworm

# Install Python dependencies
COPY requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

# Copy app
RUN mkdir -p /opt/django-app
ADD order_api/ /opt/django-app/

# Launch app
WORKDIR /opt/django-app
EXPOSE 8000
ENTRYPOINT ["python", "manage.py", "runserver", "0.0.0.0:8000"]
