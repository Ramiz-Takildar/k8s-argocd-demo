#!/bin/bash

# Script to access the demo application
# This script will set up port forwarding to access the app

set -e

echo "=========================================="
echo "Demo Application Access"
echo "=========================================="
echo ""

# Check if deployment exists
if ! kubectl get deployment demo-app -n demo-app &> /dev/null; then
    echo "❌ Error: demo-app deployment not found!"
    echo "Please deploy the application first: ./scripts/deploy-app.sh"
    exit 1
fi

# Check if pods are ready
READY_PODS=$(kubectl get pods -n demo-app -l app=demo-app --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l | tr -d ' ')

if [ "$READY_PODS" -eq 0 ]; then
    echo "❌ Error: No running pods found!"
    echo "Please check deployment status: kubectl get pods -n demo-app"
    exit 1
fi

echo "✅ Found $READY_PODS running pod(s)"
echo ""
echo "=========================================="
echo "Starting Port Forward"
echo "=========================================="
echo ""
echo "Forwarding local port 3000 to demo-app service..."
echo ""
echo "Access the application at: http://localhost:3000"
echo ""
echo "Press Ctrl+C to stop port forwarding"
echo ""

kubectl port-forward -n demo-app svc/demo-app-service 3000:80
