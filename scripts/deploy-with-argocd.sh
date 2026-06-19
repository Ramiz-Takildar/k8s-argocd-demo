#!/bin/bash

# Deploy application using ArgoCD (GitOps way)
# This script will:
# 1. Verify ArgoCD is installed
# 2. Create ArgoCD application
# 3. Wait for sync
# 4. Provide access instructions
# Usage: ./scripts/deploy-with-argocd.sh

set -e

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "=========================================="
echo "Deploy with ArgoCD (GitOps)"
echo "=========================================="
echo ""

# Check if ArgoCD is installed
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ Error: ArgoCD is not installed!"
    echo "Please install ArgoCD first: ./scripts/install-argocd.sh"
    exit 1
fi

echo "✅ ArgoCD is installed"
echo ""

# Apply ArgoCD application
echo "Creating ArgoCD application..."
kubectl apply -f "$PROJECT_ROOT/k8s/argocd/application.yaml"

echo ""
echo "Waiting for ArgoCD to sync the application..."
sleep 5

# Wait for application to be created
for i in {1..30}; do
    if kubectl get application demo-app -n argocd &> /dev/null; then
        echo "✅ ArgoCD application created"
        break
    fi
    echo "Waiting for application to be created... ($i/30)"
    sleep 2
done

# Wait for sync
echo ""
echo "Waiting for ArgoCD to sync resources..."
sleep 10

# Check if deployment is ready
echo "Waiting for deployment to be ready..."
for i in {1..60}; do
    if kubectl get deployment demo-app -n demo-app &> /dev/null; then
        READY=$(kubectl get deployment demo-app -n demo-app -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        DESIRED=$(kubectl get deployment demo-app -n demo-app -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "3")
        
        if [ "$READY" = "$DESIRED" ]; then
            echo "✅ All $READY/$DESIRED replicas are ready!"
            break
        else
            echo "Waiting for pods to be ready: $READY/$DESIRED ($i/60)"
            sleep 5
        fi
    else
        echo "Waiting for deployment to be created... ($i/60)"
        sleep 5
    fi
done

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
echo ""

# Show application status
kubectl get pods -n demo-app
echo ""

# Get ArgoCD password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)

echo "=========================================="
echo "Access Information"
echo "=========================================="
echo ""
echo "📱 Portfolio Application:"
echo "   Run: ./scripts/access-app.sh"
echo "   Or manually:"
echo "   kubectl port-forward -n demo-app svc/demo-app-service 3000:80"
echo "   Then visit: http://localhost:3000"
echo ""
echo "🔄 ArgoCD UI:"
echo "   Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "   Then visit: https://localhost:8080"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "📊 Check ArgoCD Application Status:"
echo "   kubectl get application -n argocd"
echo "   kubectl describe application demo-app -n argocd"
echo ""
echo "🔍 View Application in ArgoCD UI to see:"
echo "   - Real-time sync status"
echo "   - Resource health"
echo "   - Deployment history"
echo "   - GitOps workflow in action"
echo ""
