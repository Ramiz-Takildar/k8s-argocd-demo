#!/bin/bash

# Build and load Docker image into Kind cluster
# Usage: ./scripts/build-and-load.sh

set -e

echo "Building Docker image..."
docker build -t demo-app:v1.0.0 ./app

echo "Loading image into Kind cluster..."
kind load docker-image demo-app:v1.0.0 --name dev-cluster

echo "Image loaded successfully!"
