#!/bin/bash

# EC2 Setup Script - Run this on your EC2 instance after SSH
# This script installs all prerequisites and deploys the application

set -e

echo "🚀 Starting EC2 Setup for Microservices Application..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${GREEN}==>${NC} $1"
}

print_error() {
    echo -e "${RED}ERROR:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}WARNING:${NC} $1"
}

# Check if running as ubuntu user
if [ "$USER" != "ubuntu" ]; then
    print_warning "This script should be run as ubuntu user"
fi

# Step 1: Update system
print_step "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Step 2: Install Docker
print_step "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ubuntu
    rm get-docker.sh
    print_step "Docker installed! Please log out and back in for group changes to take effect."
    print_warning "After logging back in, run this script again."
    exit 0
else
    print_step "Docker already installed"
fi

# Verify Docker is running
if ! docker ps &> /dev/null; then
    print_error "Docker is not running or you need to log out and back in"
    exit 1
fi

# Step 3: Install k3s (Lightweight Kubernetes)
print_step "Installing k3s Kubernetes..."
if ! command -v kubectl &> /dev/null; then
    curl -sfL https://get.k3s.io | sh -
    
    # Wait for k3s to start
    sleep 10
    
    # Set up kubectl access
    mkdir -p ~/.kube
    sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
    sudo chown ubuntu:ubuntu ~/.kube/config
    export KUBECONFIG=~/.kube/config
    
    # Add to bashrc
    echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
    
    print_step "Kubernetes (k3s) installed!"
else
    print_step "Kubernetes already installed"
fi

# Verify Kubernetes
kubectl cluster-info &> /dev/null
if [ $? -ne 0 ]; then
    print_error "Kubernetes is not running properly"
    exit 1
fi

# Step 4: Install Git
print_step "Installing Git..."
if ! command -v git &> /dev/null; then
    sudo apt install git -y
fi

# Step 5: Install Make (optional but useful)
print_step "Installing Make..."
if ! command -v make &> /dev/null; then
    sudo apt install make -y
fi

# Step 6: Install kubectl (if not already from k3s)
if ! command -v kubectl &> /dev/null; then
    print_step "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
fi

# Step 7: Configure firewall (if UFW is active)
if sudo ufw status | grep -q "Status: active"; then
    print_step "Configuring firewall..."
    sudo ufw allow 22/tcp    # SSH
    sudo ufw allow 30080/tcp # Frontend
    sudo ufw allow 30090/tcp # Prometheus
    sudo ufw allow 30300/tcp # Grafana
    sudo ufw allow 6443/tcp  # Kubernetes API
fi

# Step 8: Increase file limits
print_step "Configuring system limits..."
sudo bash -c 'cat >> /etc/security/limits.conf << EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 65536
* hard nproc 65536
EOF'

# Step 9: Print success message
echo ""
echo "✅ EC2 Setup Complete!"
echo ""
echo "Installed:"
echo "  - Docker $(docker --version | cut -d ' ' -f3)"
echo "  - Kubernetes (k3s)"
echo "  - kubectl $(kubectl version --client --short 2>/dev/null | cut -d ' ' -f3)"
echo "  - Git $(git --version | cut -d ' ' -f3)"
echo ""
echo "Next steps:"
echo "1. Clone your GitHub repository:"
echo "   git clone https://github.com/YOUR_USERNAME/microservices-k8s-project.git"
echo ""
echo "2. Navigate to the project:"
echo "   cd microservices-k8s-project"
echo ""
echo "3. Build and deploy:"
echo "   ./scripts/ec2-deploy.sh"
echo ""
echo "Or use the Makefile:"
echo "   make deploy"
echo ""
echo "Your EC2 Public IP:"
curl -s http://169.254.169.254/latest/meta-data/public-ipv4
echo ""
echo ""
echo "Access URLs (after deployment):"
echo "  Frontend:   http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):30080"
echo "  Prometheus: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):30090"
echo "  Grafana:    http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):30300"
echo ""
