#!/bin/bash

# EC2 Deployment Script
# Run this script on EC2 after cloning the repository

set -e

echo "🚀 Deploying Microservices Application on EC2..."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

# Get EC2 public IP
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Step 1: Build Docker images
print_step "Building Docker images..."
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend

print_step "Docker images built successfully!"
docker images | grep -E "backend|frontend"

# Step 2: Deploy database and cache
print_step "Deploying PostgreSQL and Redis..."
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/redis-deployment.yaml

# Wait for database and cache
print_step "Waiting for database and cache to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s || true
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s || true

# Step 3: Deploy backend
print_step "Deploying backend API..."
kubectl apply -f k8s/backend-deployment.yaml

# Wait for backend
print_step "Waiting for backend to be ready..."
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s || true

# Step 4: Deploy frontend
print_step "Deploying frontend..."
kubectl apply -f k8s/frontend-deployment.yaml

# Wait for frontend
print_step "Waiting for frontend to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend --timeout=120s || true

# Step 5: Deploy monitoring (optional)
read -p "Deploy monitoring stack (Prometheus + Grafana)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_step "Deploying Prometheus and Grafana..."
    kubectl apply -f k8s/prometheus-deployment.yaml
    kubectl apply -f k8s/grafana-deployment.yaml
    
    print_step "Waiting for monitoring to be ready..."
    kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=120s || true
    kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=120s || true
fi

# Step 6: Verify deployment
echo ""
print_step "Deployment Status:"
echo ""
kubectl get pods --all-namespaces
echo ""
kubectl get services --all-namespaces
echo ""

# Step 7: Print access URLs
echo ""
echo "✅ Deployment Complete!"
echo ""
echo "═══════════════════════════════════════════════"
echo "  Access Your Application"
echo "═══════════════════════════════════════════════"
echo ""
echo "📱 Frontend:   http://${EC2_IP}:30080"
echo "📊 Prometheus: http://${EC2_IP}:30090"
echo "📈 Grafana:    http://${EC2_IP}:30300"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "═══════════════════════════════════════════════"
echo ""
echo "Useful commands:"
echo "  View logs:    kubectl logs -f deployment/backend"
echo "  Check status: kubectl get pods"
echo "  Restart:      kubectl rollout restart deployment/backend"
echo "  Scale up:     kubectl scale deployment backend --replicas=3"
echo ""
echo "To update after code changes:"
echo "  git pull origin main"
echo "  docker build -t backend:latest ./backend"
echo "  docker build -t frontend:latest ./frontend"
echo "  kubectl rollout restart deployment/backend"
echo "  kubectl rollout restart deployment/frontend"
echo ""
