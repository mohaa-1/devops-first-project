#!/bin/bash

# Quick Update Script for EC2
# Run this to pull latest changes and redeploy

set -e

echo "🔄 Updating application from GitHub..."

# Colors
GREEN='\033[0;32m'
NC='\033[0m'

print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

# Get EC2 IP
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Pull latest changes
print_step "Pulling latest code from GitHub..."
git pull origin main

# Rebuild images
print_step "Rebuilding Docker images..."
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend

# Restart deployments
print_step "Restarting deployments..."
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend

# Wait for rollout
print_step "Waiting for rollout to complete..."
kubectl rollout status deployment/backend
kubectl rollout status deployment/frontend

# Show status
print_step "Current pod status:"
kubectl get pods

echo ""
echo "✅ Update complete!"
echo ""
echo "Application running at:"
echo "  Frontend: http://${EC2_IP}:30080"
echo ""
