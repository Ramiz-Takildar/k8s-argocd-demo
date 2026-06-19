#!/bin/bash

# Stop all port-forwards for the demo
# Usage: ./scripts/stop-port-forwards.sh

echo "=========================================="
echo "Stopping Port Forwards"
echo "=========================================="
echo ""

# Kill port-forwards on port 3000 (app)
if lsof -ti:3000 > /dev/null 2>&1; then
    echo "Stopping portfolio application port-forward (port 3000)..."
    lsof -ti:3000 | xargs kill -9 2>/dev/null
    echo "✅ Stopped"
else
    echo "ℹ️  No port-forward running on port 3000"
fi

echo ""

# Kill port-forwards on port 8080 (ArgoCD)
if lsof -ti:8080 > /dev/null 2>&1; then
    echo "Stopping ArgoCD UI port-forward (port 8080)..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null
    echo "✅ Stopped"
else
    echo "ℹ️  No port-forward running on port 8080"
fi

echo ""
echo "=========================================="
echo "✅ All port-forwards stopped"
echo "=========================================="
echo ""
