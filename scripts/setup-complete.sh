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

# Step 1: Build and load image
echo "Step 1: Building and loading Docker image..."
./scripts/build-and-load.sh
echo ""

# Step 2: Install ArgoCD
echo "Step 2: Installing ArgoCD..."
./scripts/install-argocd.sh
echo ""

# Step 3: Deploy application
echo "Step 3: Deploying application..."
./scripts/deploy-app.sh
echo ""

echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📝 Next Steps:"
echo ""
echo "1. Access the application:"
echo "   curl http://localhost:30080"
echo ""
echo "2. Access ArgoCD UI:"
echo "   https://localhost:30443"
echo "   Username: admin"
echo "   Password: (shown above)"
echo ""
echo "3. To use ArgoCD for GitOps deployment:"
echo "   - Push this project to a Git repository"
echo "   - Update k8s/argocd/application.yaml with your repo URL"
echo "   - Apply: kubectl apply -f k8s/argocd/application.yaml"
echo ""
echo "Happy Learning! 🎓"
