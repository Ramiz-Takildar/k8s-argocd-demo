# Kubernetes + ArgoCD Demo Project

A complete demonstration project for teaching students about Kubernetes deployments and GitOps with ArgoCD. Features automated setup, GitOps workflows, and production-ready patterns.

## 📋 Prerequisites

- Docker installed
- Kind (Kubernetes in Docker) installed
- kubectl installed
- Git installed

## 🏗️ Project Structure

```
k8s-argocd-demo/
├── app/
│   ├── server.js          # Simple Node.js Express application
│   ├── package.json       # Node.js dependencies
│   ├── Dockerfile         # Container image definition
│   └── public/            # Static web assets
│       ├── index.html     # Portfolio landing page
│       └── style.css      # Styling
├── k8s/
│   ├── base/
│   │   ├── namespace.yaml    # Kubernetes namespace
│   │   ├── deployment.yaml   # Application deployment (4 replicas)
│   │   └── service.yaml      # Service (NodePort 30081)
│   └── argocd/
│       └── application.yaml  # ArgoCD application definition
└── scripts/
    ├── setup-complete.sh         # Complete automated setup
    ├── build-and-load.sh         # Build and load image to Kind
    ├── install-argocd.sh         # Install ArgoCD
    ├── deploy-app.sh             # Deploy app manually
    ├── start-port-forwards.sh    # Start both port-forwards
    ├── stop-port-forwards.sh     # Stop all port-forwards
    └── cleanup.sh                # Cleanup (preserves cluster)
```

## 🚀 Quick Start Guide (Recommended)

### One-Command Setup

```bash
# 1. Create Kind cluster (from directory containing kind-config.yaml)
kind create cluster --name dev-cluster --config kind-config.yaml

# 2. Run complete setup (does everything!)
cd k8s-argocd-demo
./scripts/setup-complete.sh

# 3. Start port-forwards for easy access
./scripts/start-port-forwards.sh
```

**That's it!** The setup script automatically:
- ✅ Builds and loads Docker image
- ✅ Installs ArgoCD
- ✅ Deploys application manually
- ✅ Creates ArgoCD Application for GitOps
- ✅ Configures auto-sync

**Access Your Services:**
- Portfolio: http://localhost:3000
- ArgoCD UI: https://localhost:8081

## 📖 Detailed Setup Guide

### Step 1: Create Kind Cluster

```bash
# From directory containing kind-config.yaml
kind create cluster --name dev-cluster --config kind-config.yaml
```

### Step 2: Complete Automated Setup

```bash
cd k8s-argocd-demo
chmod +x scripts/*.sh
./scripts/setup-complete.sh
```

This single script handles everything:
1. Builds Docker image (demo-app:v1.0.0)
2. Loads image into Kind cluster
3. Installs ArgoCD v2.8.4
4. Deploys application (4 replicas)
5. Creates ArgoCD Application
6. Configures GitOps auto-sync

### Step 3: Access Services

**Easy Access (Recommended):**
```bash
./scripts/start-port-forwards.sh
```

This starts both services:
- Portfolio: http://localhost:3000
- ArgoCD: https://localhost:8081

**Stop Port-Forwards:**
```bash
./scripts/stop-port-forwards.sh
```

**Manual Port-Forward (Alternative):**
```bash
# Portfolio app
kubectl port-forward -n demo-app svc/demo-app-service 3000:80

# ArgoCD UI
kubectl port-forward -n argocd svc/argocd-server 8081:443
```

## 🎯 Alternative Deployment Methods

### Option A: Manual Deployment (Without ArgoCD)

```bash
./scripts/build-and-load.sh
./scripts/deploy-app.sh
```

### Option B: ArgoCD UI Deployment

1. Install ArgoCD: `./scripts/install-argocd.sh`
2. Start port-forward: `./scripts/start-port-forwards.sh`
3. Access UI: https://localhost:8081
4. Click "New App" and configure:
   - Application Name: `demo-app`
   - Project: `default`
   - Sync Policy: `Automatic`
   - Repository: `https://github.com/Ramiz-Takildar/k8s-argocd-demo.git`
   - Path: `k8s/base`
   - Cluster: `https://kubernetes.default.svc`
   - Namespace: `demo-app`

### Option C: ArgoCD CLI Deployment

```bash
# Install ArgoCD CLI
brew install argocd  # macOS

# Login
argocd login localhost:8081 --insecure

# Create application
argocd app create demo-app \
  --repo https://github.com/Ramiz-Takildar/k8s-argocd-demo.git \
  --path k8s/base \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace demo-app \
  --sync-policy automated
```

## 🧪 Testing the Application

```bash
# Check deployment status
kubectl get pods -n demo-app
kubectl get deployment -n demo-app
kubectl get svc -n demo-app

# Check ArgoCD sync status
kubectl get application demo-app -n argocd

# Test the application
curl http://localhost:3000

# Expected response:
{
  "message": "Hello from Kubernetes + ArgoCD Demo!",
  "timestamp": "2026-06-19T00:00:00.000Z",
  "hostname": "demo-app-xxxxx-xxxxx",
  "version": "v1.0.0"
}

# Check health endpoint
curl http://localhost:3000/health
```

## 🔄 GitOps Demo - Making Changes

### Example: Scale Deployment

1. **Edit deployment:**
   ```bash
   # Change replicas from 4 to 5 in k8s/base/deployment.yaml
   vim k8s/base/deployment.yaml
   ```

2. **Commit and push:**
   ```bash
   git add k8s/base/deployment.yaml
   git commit -m "Scale to 5 replicas"
   git push
   ```

3. **Watch ArgoCD auto-sync:**
   ```bash
   # ArgoCD detects change within 3 minutes
   kubectl get application demo-app -n argocd -w
   
   # Watch pods scale up
   kubectl get pods -n demo-app -w
   ```

### Example: Update Application Version

1. **Update code and image:**
   ```bash
   # Edit app/server.js - change version to v1.1.0
   # Edit k8s/base/deployment.yaml - change image tag to v1.1.0
   ```

2. **Build and load new image:**
   ```bash
   docker build -t demo-app:v1.1.0 ./app
   kind load docker-image demo-app:v1.1.0 --name dev-cluster
   ```

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "Update to v1.1.0"
   git push
   ```

4. **ArgoCD syncs automatically!**

## 🧹 Cleanup

### Quick Cleanup (Preserves Cluster)

```bash
./scripts/cleanup.sh
```

This removes:
- Demo application namespace
- ArgoCD namespace (optional)
- Docker images (optional)

**Cluster is preserved** for quick redeployment!

### Complete Cleanup (Including Cluster)

```bash
./scripts/cleanup.sh
kind delete cluster --name dev-cluster
```

### Quick Redeploy After Cleanup

```bash
./scripts/setup-complete.sh
./scripts/start-port-forwards.sh
```

## 📚 Learning Objectives

### For Students:

1. **Containerization**
   - Understanding Dockerfile
   - Building container images
   - Loading images into Kind cluster
   - Image versioning and tagging

2. **Kubernetes Basics**
   - Namespaces for resource isolation
   - Deployments for managing pods
   - Services for networking (NodePort)
   - Health checks (liveness/readiness probes)
   - Resource limits and requests
   - Replica management and scaling

3. **GitOps with ArgoCD**
   - Declarative configuration
   - Automated synchronization
   - Self-healing applications
   - Git as single source of truth
   - Continuous deployment
   - Rollback capabilities

4. **Production Patterns**
   - Multi-replica deployments
   - Health monitoring
   - Resource management
   - Port-forwarding for local access
   - Automated setup scripts

## 🎯 Key Features

- ✅ **Automated Setup**: One script does everything
- ✅ **GitOps Ready**: ArgoCD auto-sync configured
- ✅ **Production Patterns**: 4 replicas, health checks, resource limits
- ✅ **Easy Access**: Port-forward scripts for both services
- ✅ **Quick Cleanup**: Preserves cluster for fast redeployment
- ✅ **Self-Healing**: ArgoCD ensures desired state
- ✅ **Modern UI**: Responsive portfolio landing page

## 📖 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [GitOps Principles](https://www.gitops.tech/)

## 🎯 Key Concepts Demonstrated

- **Containerization**: Packaging applications in Docker
- **Orchestration**: Managing containers with Kubernetes
- **GitOps**: Using Git as source of truth for infrastructure
- **Continuous Deployment**: Automated application updates
- **Self-Healing**: Automatic recovery from failures
- **Declarative Configuration**: Describing desired state
- **High Availability**: Multiple replicas for resilience

## 💡 Tips for Students

1. **Debugging:**
   ```bash
   kubectl logs -n demo-app <pod-name>
   kubectl describe pod -n demo-app <pod-name>
   kubectl get events -n demo-app --sort-by='.lastTimestamp'
   ```

2. **ArgoCD Monitoring:**
   ```bash
   kubectl get application demo-app -n argocd -w
   kubectl describe application demo-app -n argocd
   ```

3. **Testing Changes:**
   - Make small changes to test GitOps workflow
   - Watch ArgoCD detect and sync changes
   - Observe self-healing by deleting a pod

4. **Port-Forward Management:**
   - Use scripts for easy access
   - Check running port-forwards: `ps aux | grep port-forward`
   - Kill specific port-forward: `kill <PID>`

## 🔧 Troubleshooting

### Pods Not Starting
```bash
kubectl describe pod -n demo-app <pod-name>
kubectl logs -n demo-app <pod-name>
```

### ArgoCD Not Syncing
```bash
kubectl get application demo-app -n argocd
kubectl describe application demo-app -n argocd
```

### Port-Forward Issues
```bash
# Stop all port-forwards
./scripts/stop-port-forwards.sh

# Restart
./scripts/start-port-forwards.sh
```

### Image Pull Issues
```bash
# Rebuild and reload image
./scripts/build-and-load.sh
```

## 🤝 Contributing

This is a learning project. Feel free to:
- Add more features to the application
- Experiment with different Kubernetes resources
- Try different ArgoCD sync policies
- Add monitoring and logging
- Implement CI/CD pipelines

## 📊 Current Configuration

- **Application**: Node.js Express portfolio
- **Image**: demo-app:v1.0.0
- **Replicas**: 4
- **Service Port**: 30081 (NodePort)
- **ArgoCD Version**: v2.8.4
- **Auto-Sync**: Enabled
- **Self-Heal**: Enabled

---

**Happy Learning! 🎓🚀**

**Repository**: https://github.com/Ramiz-Takildar/k8s-argocd-demo