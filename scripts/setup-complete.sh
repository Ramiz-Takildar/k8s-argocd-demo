#!/bin/bash

# Complete setup script for the demo
# This script will:
# 1. Build and load the Docker image
# 2. Install ArgoCD
# 3. Deploy the application manually
# Usage: ./scripts/setup-complete.sh

set -e

echo "=========================================="
echo "K8s + ArgoCD Demo - Complete Setup"
echo "=========================================="
echo ""

# Check if Kind cluster is running
if ! kind get clusters | grep -q "dev-cluster"; then
    echo "❌ Error: Kind cluster 'dev-cluster' not found!"
    echo "Please create the cluster first:"
    echo "  cd /Users/ramiz/Kind-Cluster"
    echo "  kind create cluster --name dev-cluster --config kind-config.yaml"
    exit 1
fi

echo "✅ Kind cluster 'dev-cluster' found"
echo ""

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Step 1: Build and load image
echo "Step 1: Building and loading Docker image..."
bash "$SCRIPT_DIR/build-and-load.sh"
echo ""

# Step 2: Install ArgoCD
echo "Step 2: Installing ArgoCD..."
bash "$SCRIPT_DIR/install-argocd.sh"
echo ""

# Step 3: Deploy application manually
echo "Step 3: Deploying application manually..."
bash "$SCRIPT_DIR/deploy-app.sh"
echo ""

# Step 4: Deploy ArgoCD Application for GitOps
echo "Step 4: Setting up ArgoCD GitOps..."
echo "Creating ArgoCD Application..."
kubectl apply -f "$PROJECT_ROOT/k8s/argocd/application.yaml"
echo "✅ ArgoCD Application created"
echo ""
echo "Waiting for ArgoCD to sync..."
sleep 10
kubectl get application demo-app -n argocd
echo ""

echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📝 Access Your Services:"
echo ""
echo "1. Portfolio Application:"
echo "   http://localhost:30081"
echo ""
echo "2. ArgoCD UI:"
echo "   https://localhost:30443"
echo "   Username: admin"
echo "   Password: (shown above)"
echo ""
echo "3. Start port-forwards for easier access:"
echo "   ./scripts/start-port-forwards.sh"
echo "   Then access:"
echo "   - Portfolio: http://localhost:3000"
echo "   - ArgoCD: https://localhost:8081"
echo ""
echo "Happy Learning! 🎓"
