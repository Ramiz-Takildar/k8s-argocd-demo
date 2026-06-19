#!/bin/bash

# Start port-forwarding for both Application and ArgoCD
# This script will run both port-forwards in the background
# Usage: ./scripts/start-port-forwards.sh

set -e

echo "=========================================="
echo "Starting Port Forwards"
echo "=========================================="
echo ""

# Check if demo-app exists
if ! kubectl get namespace demo-app &> /dev/null; then
    echo "❌ Error: demo-app namespace not found!"
    echo "Please deploy the application first."
    exit 1
fi

# Check if ArgoCD exists
if ! kubectl get namespace argocd &> /dev/null; then
    echo "⚠️  Warning: ArgoCD namespace not found!"
    echo "ArgoCD port-forward will be skipped."
    SKIP_ARGOCD=true
fi

# Kill any existing port-forwards on these ports
echo "Cleaning up any existing port-forwards..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true
lsof -ti:8081 | xargs kill -9 2>/dev/null || true

echo ""
echo "Starting port-forwards..."
echo ""

# Start application port-forward
echo "📱 Starting portfolio application port-forward..."
kubectl port-forward -n demo-app svc/demo-app-service 3000:80 > /tmp/app-port-forward.log 2>&1 &
APP_PID=$!
echo "   PID: $APP_PID"
echo "   URL: http://localhost:3000"

sleep 2

# Start ArgoCD port-forward if available
if [ "$SKIP_ARGOCD" != "true" ]; then
    echo ""
    echo "🔄 Starting ArgoCD UI port-forward..."
    kubectl port-forward -n argocd svc/argocd-server 8081:443 > /tmp/argocd-port-forward.log 2>&1 &
    ARGOCD_PID=$!
    echo "   PID: $ARGOCD_PID"
    echo "   URL: https://localhost:8081"
    
    # Get ArgoCD password
    sleep 2
    ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)
fi

echo ""
echo "=========================================="
echo "✅ Port Forwards Active!"
echo "=========================================="
echo ""
echo "📱 Portfolio Application:"
echo "   http://localhost:3000"
echo ""

if [ "$SKIP_ARGOCD" != "true" ]; then
    echo "🔄 ArgoCD UI:"
    echo "   https://localhost:8081"
    echo "   Username: admin"
    echo "   Password: $ARGOCD_PASSWORD"
    echo ""
fi

echo "Process IDs:"
echo "   App: $APP_PID"
if [ "$SKIP_ARGOCD" != "true" ]; then
    echo "   ArgoCD: $ARGOCD_PID"
fi

echo ""
echo "To stop port-forwards:"
echo "   kill $APP_PID"
if [ "$SKIP_ARGOCD" != "true" ]; then
    echo "   kill $ARGOCD_PID"
fi
echo ""
echo "Or use: ./scripts/stop-port-forwards.sh"
echo ""
echo "Logs:"
echo "   App: /tmp/app-port-forward.log"
if [ "$SKIP_ARGOCD" != "true" ]; then
    echo "   ArgoCD: /tmp/argocd-port-forward.log"
fi
echo ""
echo "Press Ctrl+C to stop this script (port-forwards will continue in background)"
echo ""

# Keep script running
wait
