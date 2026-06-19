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
echo "Waiting for Kubernetes to create deployment object..."

# Wait for deployment to exist (with retry)
for i in {1..30}; do
    if kubectl get deployment demo-app -n demo-app &> /dev/null; then
        echo "✅ Deployment found!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "❌ Error: Deployment was not created after 30 seconds"
        exit 1
    fi
    sleep 1
done

echo "Giving pods time to start (health checks need ~15-20 seconds)..."
sleep 15

echo "Waiting for all replicas to be ready..."
kubectl wait --for=condition=available --timeout=120s deployment/demo-app -n demo-app
echo ""
echo "✅ Deployment is ready!"
kubectl get pods -n demo-app

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
