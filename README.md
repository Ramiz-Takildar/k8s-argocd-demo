# Kubernetes + ArgoCD Demo Project

A simple demonstration project for teaching students about Kubernetes deployments and GitOps with ArgoCD.

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
│   └── Dockerfile         # Container image definition
├── k8s/
│   ├── base/
│   │   ├── namespace.yaml    # Kubernetes namespace
│   │   ├── deployment.yaml   # Application deployment
│   │   └── service.yaml      # Service (NodePort)
│   └── argocd/
│       └── application.yaml  # ArgoCD application definition
└── scripts/
    ├── build-and-load.sh     # Build and load image to Kind
    ├── install-argocd.sh     # Install ArgoCD
    └── deploy-app.sh         # Deploy app manually
```

## 🚀 Quick Start Guide

### Step 1: Create Kind Cluster

```bash
# Navigate to the Kind-Cluster directory
cd /Users/ramiz/Kind-Cluster

# Create the cluster using the existing config
kind create cluster --name dev-cluster --config kind-config.yaml
```

### Step 2: Build and Load Application Image

```bash
cd k8s-argocd-demo

# Make scripts executable
chmod +x scripts/*.sh

# Build Docker image and load into Kind cluster
./scripts/build-and-load.sh
```

### Step 3: Option A - Manual Deployment (Without ArgoCD)

```bash
# Deploy the application directly
./scripts/deploy-app.sh

# Access the application
curl http://localhost:30080
```

### Step 4: Option B - Deploy with ArgoCD (GitOps Way)

#### 4.1 Install ArgoCD

```bash
./scripts/install-argocd.sh
```

This will:
- Install ArgoCD in the cluster
- Expose ArgoCD UI on port 30443
- Display the admin password

#### 4.2 Access ArgoCD UI

```bash
# Open in browser (accept self-signed certificate warning)
open https://localhost:30443

# Login credentials:
# Username: admin
# Password: (displayed by install script)
```

#### 4.3 Deploy Application via ArgoCD

**Option 1: Using kubectl**
```bash
kubectl apply -f k8s/argocd/application.yaml
```

**Option 2: Using ArgoCD UI**
1. Click "New App"
2. Fill in:
   - Application Name: `demo-app`
   - Project: `default`
   - Sync Policy: `Automatic`
   - Repository URL: Your Git repository URL
   - Path: `k8s/base`
   - Cluster: `https://kubernetes.default.svc`
   - Namespace: `demo-app`
3. Click "Create"

**Option 3: Using ArgoCD CLI**
```bash
# Install ArgoCD CLI
brew install argocd  # macOS
# or download from https://argo-cd.readthedocs.io/en/stable/cli_installation/

# Login to ArgoCD
argocd login localhost:30443 --insecure

# Create application
argocd app create demo-app \
  --repo https://github.com/YOUR_USERNAME/k8s-argocd-demo.git \
  --path k8s/base \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace demo-app \
  --sync-policy automated
```

## 🧪 Testing the Application

```bash
# Check if pods are running
kubectl get pods -n demo-app

# Check service
kubectl get svc -n demo-app

# Test the application
curl http://localhost:30080

# Expected response:
# {
#   "message": "Hello from Kubernetes + ArgoCD Demo!",
#   "timestamp": "2026-06-19T00:00:00.000Z",
#   "hostname": "demo-app-xxxxx-xxxxx",
#   "version": "v1.0.0"
# }

# Check health endpoint
curl http://localhost:30080/health
```

## 📚 Learning Objectives

### For Students:

1. **Containerization**
   - Understanding Dockerfile
   - Building container images
   - Loading images into Kind cluster

2. **Kubernetes Basics**
   - Namespaces for resource isolation
   - Deployments for managing pods
   - Services for networking
   - Health checks (liveness/readiness probes)
   - Resource limits and requests

3. **GitOps with ArgoCD**
   - Declarative configuration
   - Automated synchronization
   - Self-healing applications
   - Git as single source of truth

## 🔄 Making Changes (GitOps Demo)

1. **Update the application version:**
   ```bash
   # Edit app/server.js and change version to v1.1.0
   # Edit k8s/base/deployment.yaml and update image tag to v1.1.0
   ```

2. **Rebuild and reload:**
   ```bash
   docker build -t demo-app:v1.1.0 ./app
   kind load docker-image demo-app:v1.1.0 --name dev-cluster
   ```

3. **Commit and push changes:**
   ```bash
   git add .
   git commit -m "Update to v1.1.0"
   git push
   ```

4. **Watch ArgoCD sync automatically** (if using ArgoCD)
   - ArgoCD will detect changes and sync automatically
   - View in ArgoCD UI or CLI

## 🧹 Cleanup

```bash
# Delete the application
kubectl delete -f k8s/base/

# Or if using ArgoCD
kubectl delete -f k8s/argocd/application.yaml

# Delete ArgoCD
kubectl delete namespace argocd

# Delete the Kind cluster
kind delete cluster --name dev-cluster
```

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

## 💡 Tips for Students

1. Always check pod logs: `kubectl logs -n demo-app <pod-name>`
2. Describe resources for details: `kubectl describe pod -n demo-app <pod-name>`
3. Use `kubectl get events -n demo-app` to troubleshoot issues
4. ArgoCD UI provides visual representation of your application state
5. Practice making changes and watching ArgoCD sync them automatically

## 🤝 Contributing

This is a learning project. Feel free to:
- Add more features to the application
- Experiment with different Kubernetes resources
- Try different ArgoCD sync policies
- Add monitoring and logging

---

**Happy Learning! 🎓**
