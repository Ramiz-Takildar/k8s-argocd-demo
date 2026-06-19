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
echo "Checking if deployment exists..."
for i in {1..30}; do
    if kubectl get deployment demo-app -n demo-app &> /dev/null; then
        echo "Deployment found, waiting for pods to be ready..."
        kubectl wait --for=condition=available --timeout=120s deployment/demo-app -n demo-app && break
        echo "Still waiting... (attempt $i/30)"
        sleep 5
    else
        echo "Deployment not yet created, waiting... (attempt $i/30)"
        sleep 2
    fi
done

# Final check
if kubectl get deployment demo-app -n demo-app &> /dev/null; then
    echo "✅ Deployment is ready!"
    kubectl get pods -n demo-app
else
    echo "❌ Error: Deployment was not created successfully"
    exit 1
fi

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
