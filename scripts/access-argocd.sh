#!/bin/bash

# Script to access ArgoCD UI
# This script will set up port forwarding and display access information

set -e

echo "=========================================="
echo "ArgoCD Access Setup"
echo "=========================================="
echo ""

# Check if ArgoCD is installed
if ! kubectl get namespace argocd &> /dev/null; then
    echo "❌ Error: ArgoCD namespace not found!"
    echo "Please install ArgoCD first: ./scripts/install-argocd.sh"
    exit 1
fi

# Get ArgoCD admin password
echo "Getting ArgoCD admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)

if [ -z "$ARGOCD_PASSWORD" ]; then
    echo "❌ Error: Could not retrieve ArgoCD password"
    exit 1
fi

echo ""
echo "✅ ArgoCD is installed and ready!"
echo ""
echo "=========================================="
echo "Access Information"
echo "=========================================="
echo ""
echo "Option 1: Using Port Forward (Recommended)"
echo "-------------------------------------------"
echo "Run this command in a separate terminal:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "Then access ArgoCD at: https://localhost:8080"
echo ""
echo "Option 2: Using NodePort"
echo "-------------------------------------------"
echo "Access ArgoCD at: https://localhost:30443"
echo "(Note: May not work on all systems)"
echo ""
echo "=========================================="
echo "Login Credentials"
echo "=========================================="
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""
echo "Note: Accept the self-signed certificate warning in your browser"
echo ""
