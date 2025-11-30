# Kubernetes Deployment Guide

This directory contains Kubernetes manifests for deploying the DevOps Flask application.

## Prerequisites

- Kubernetes cluster (minikube, Docker Desktop, EKS, GKE, AKS)
- `kubectl` CLI installed and configured
- Docker image built: `devops-app:latest`

## Quick Start

### 1. Build Docker Image

```bash
cd .vscode
docker build -t devops-app:latest .
```

### 2. Deploy to Kubernetes

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy all resources
kubectl apply -f k8s/configmap.yaml -n devops-project
kubectl apply -f k8s/deployment.yaml -n devops-project
kubectl apply -f k8s/service.yaml -n devops-project

# Optional: Deploy ingress (requires ingress controller)
kubectl apply -f k8s/ingress.yaml -n devops-project
```

### 3. Verify Deployment

```bash
# Check pods
kubectl get pods -n devops-project

# Check service
kubectl get svc -n devops-project

# Check deployment
kubectl get deployment -n devops-project
```

### 4. Access the Application

**For LoadBalancer (cloud providers):**
```bash
kubectl get svc devops-app-service -n devops-project
# Use EXTERNAL-IP to access the app
```

**For NodePort (local/minikube):**
```bash
kubectl port-forward svc/devops-app-service 8080:80 -n devops-project
# Access at http://localhost:8080
```

**For Minikube:**
```bash
minikube service devops-app-service -n devops-project
```

## Kubernetes Resources

| Resource | File | Description |
|----------|------|-------------|
| Namespace | `namespace.yaml` | Isolated namespace for the app |
| Deployment | `deployment.yaml` | 3 replicas with health checks |
| Service | `service.yaml` | LoadBalancer exposing port 80 |
| ConfigMap | `configmap.yaml` | Application configuration |
| Ingress | `ingress.yaml` | HTTP routing (optional) |

## Configuration

### Replicas

Edit `deployment.yaml`:
```yaml
spec:
  replicas: 3  # Change to desired number
```

### Resource Limits

Edit `deployment.yaml`:
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### Service Type

Edit `service.yaml` to change service type:
```yaml
spec:
  type: LoadBalancer  # Options: ClusterIP, NodePort, LoadBalancer
```

## Health Checks

The deployment includes:
- **Liveness Probe**: Checks `/health` endpoint every 10s
- **Readiness Probe**: Checks `/health` endpoint every 5s

## Scaling

```bash
# Scale manually
kubectl scale deployment devops-app --replicas=5 -n devops-project

# Auto-scaling (HPA)
kubectl autoscale deployment devops-app --cpu-percent=80 --min=3 --max=10 -n devops-project
```

## Logs and Debugging

```bash
# View logs from all pods
kubectl logs -l app=devops-app -n devops-project

# View logs from specific pod
kubectl logs <pod-name> -n devops-project

# Follow logs
kubectl logs -f -l app=devops-app -n devops-project

# Describe deployment
kubectl describe deployment devops-app -n devops-project

# Get pod details
kubectl describe pod <pod-name> -n devops-project

# Execute commands in pod
kubectl exec -it <pod-name> -n devops-project -- /bin/sh
```

## Update Deployment

```bash
# Update image
kubectl set image deployment/devops-app devops-app=devops-app:v2 -n devops-project

# Rollout status
kubectl rollout status deployment/devops-app -n devops-project

# Rollback
kubectl rollout undo deployment/devops-app -n devops-project
```

## Clean Up

```bash
# Delete all resources
kubectl delete -f k8s/ -n devops-project

# Delete namespace
kubectl delete namespace devops-project
```

## Testing

```bash
# Get service endpoint
export SERVICE_URL=$(kubectl get svc devops-app-service -n devops-project -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Test endpoints
curl http://$SERVICE_URL/
curl http://$SERVICE_URL/health
curl http://$SERVICE_URL/api/info
```

## AWS EKS Deployment

```bash
# Create EKS cluster (using eksctl)
eksctl create cluster --name devops-cluster --region eu-west-2 --nodes 3

# Get credentials
aws eks update-kubeconfig --region eu-west-2 --name devops-cluster

# Push image to ECR
aws ecr create-repository --repository-name devops-app
docker tag devops-app:latest <account-id>.dkr.ecr.eu-west-2.amazonaws.com/devops-app:latest
docker push <account-id>.dkr.ecr.eu-west-2.amazonaws.com/devops-app:latest

# Update deployment.yaml with ECR image
# Then apply manifests
kubectl apply -f k8s/
```

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n devops-project
kubectl logs <pod-name> -n devops-project
```

### Image pull errors
- Ensure Docker image exists locally (for minikube: `eval $(minikube docker-env)`)
- For cloud: push image to container registry (ECR, GCR, ACR)

### Service not accessible
- Check service type matches your environment
- For LoadBalancer: ensure cloud provider supports it
- Use port-forward for local testing

### Health checks failing
- Check `/health` endpoint returns 200
- Adjust `initialDelaySeconds` if app takes time to start
