#!/bin/bash

# Build and load Docker image into Kind cluster
# Usage: ./scripts/build-and-load.sh

set -e

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Building Docker image..."
docker build -t demo-app:v1.0.0 "$PROJECT_ROOT/app"

echo "Loading image into Kind cluster..."
kind load docker-image demo-app:v1.0.0 --name dev-cluster

echo "Image loaded successfully!"
