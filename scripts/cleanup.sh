#!/bin/bash

# Cleanup script for the K8s + ArgoCD demo
# This script will remove all deployed resources
# Usage: ./scripts/cleanup.sh

set -e

echo "=========================================="
echo "K8s + ArgoCD Demo - Cleanup"
echo "=========================================="
echo ""

# Function to ask for confirmation
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cleanup cancelled."
        exit 0
    fi
}

# Ask for confirmation
confirm "This will delete the demo application and optionally ArgoCD. Continue?"

echo ""
echo "Step 1: Deleting demo application..."
if kubectl get namespace demo-app &> /dev/null; then
    kubectl delete namespace demo-app
    echo "✅ Demo application namespace deleted"
else
    echo "ℹ️  Demo application namespace not found"
fi

echo ""
read -p "Do you want to delete ArgoCD as well? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Step 2: Deleting ArgoCD..."
    if kubectl get namespace argocd &> /dev/null; then
        kubectl delete namespace argocd
        echo "✅ ArgoCD namespace deleted"
    else
        echo "ℹ️  ArgoCD namespace not found"
    fi
else
    echo "ℹ️  Skipping ArgoCD deletion"
fi

echo ""
read -p "Do you want to delete the Kind cluster 'dev-cluster'? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Step 3: Deleting Kind cluster..."
    if kind get clusters | grep -q "dev-cluster"; then
        kind delete cluster --name dev-cluster
        echo "✅ Kind cluster deleted"
    else
        echo "ℹ️  Kind cluster 'dev-cluster' not found"
    fi
else
    echo "ℹ️  Skipping Kind cluster deletion"
fi

echo ""
read -p "Do you want to remove Docker images? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Step 4: Removing Docker images..."
    docker rmi demo-app:v1.0.0 2>/dev/null && echo "✅ Removed demo-app:v1.0.0" || echo "ℹ️  demo-app:v1.0.0 not found"
    docker rmi demo-app:v2.0.0 2>/dev/null && echo "✅ Removed demo-app:v2.0.0" || echo "ℹ️  demo-app:v2.0.0 not found"
else
    echo "ℹ️  Skipping Docker image removal"
fi

echo ""
echo "=========================================="
echo "✅ Cleanup Complete!"
echo "=========================================="
echo ""
echo "To redeploy the demo:"
echo "  ./scripts/setup-complete.sh"
echo ""
