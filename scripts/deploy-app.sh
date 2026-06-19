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
sleep 5
kubectl wait --for=condition=available --timeout=180s deployment/demo-app -n demo-app 2>/dev/null || {
    echo "Deployment is taking longer than expected. Checking status..."
    kubectl get pods -n demo-app
    echo ""
    echo "Waiting a bit more..."
    sleep 10
    kubectl wait --for=condition=available --timeout=60s deployment/demo-app -n demo-app
}

echo ""
echo "Application deployed successfully!"
echo ""
echo "To access the application, use port-forwarding:"
echo "  ./scripts/access-app.sh"
echo ""
echo "Or manually:"
echo "  kubectl port-forward -n demo-app svc/demo-app-service 3000:80"
echo "  Then visit: http://localhost:3000"
echo ""
echo "To check pods: kubectl get pods -n demo-app"
echo "To check service: kubectl get svc -n demo-app"
