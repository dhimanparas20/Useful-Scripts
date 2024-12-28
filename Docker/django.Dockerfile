# Use the smallest official Python runtime
FROM python:3.11.11-alpine

# set work directory
WORKDIR /app
COPY ./requirements.txt /app/

# set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies for Alpine
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    python3-dev \
    pkgconfig

# install dependencies
RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt    
RUN pip install -U channels["daphne"]    

    # copy project
COPY . /app/

# Expose port and specify the command to run
EXPOSE 5000
CMD ["daphne", "-b", "0.0.0.0", "-p", "5000", "project_chat.asgi:application"]
