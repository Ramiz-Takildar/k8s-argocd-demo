#!/bin/bash

# Deploy the demo application manually (without ArgoCD)
# Usage: ./scripts/deploy-app.sh

set -e

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "Applying Kubernetes manifests..."
kubectl apply -f "$PROJECT_ROOT/k8s/base/namespace.yaml"
kubectl apply -f "$PROJECT_ROOT/k8s/base/deployment.yaml"
kubectl apply -f "$PROJECT_ROOT/k8s/base/service.yaml"

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/demo-app -n demo-app

echo ""
echo "Application deployed successfully!"
echo ""
echo "Access the application at: http://localhost:30080"
echo ""
echo "To check pods: kubectl get pods -n demo-app"
echo "To check service: kubectl get svc -n demo-app"
