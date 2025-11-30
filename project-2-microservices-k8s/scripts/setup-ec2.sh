#!/bin/bash

# EC2 Setup Script for Microservices Application
# Run this script on a fresh Ubuntu EC2 instance

set -e

echo "🚀 Starting EC2 setup for microservices application..."

# Update system
echo "📦 Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
rm get-docker.sh

# Install kubectl
echo "☸️  Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install k3s (lightweight Kubernetes)
echo "☸️  Installing k3s..."
curl -sfL https://get.k3s.io | sh -
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# Configure kubectl for k3s
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config
export KUBECONFIG=~/.kube/config

# Install Git
echo "📚 Installing Git..."
sudo apt-get install -y git

# Install make
echo "🔧 Installing make..."
sudo apt-get install -y make

# Install Node.js
echo "📦 Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Python
echo "🐍 Installing Python..."
sudo apt-get install -y python3 python3-pip

# Install additional tools
echo "🛠️  Installing additional tools..."
sudo apt-get install -y curl wget unzip

# Configure Git
echo "⚙️  Configure Git (you can change these later)"
git config --global user.name "EC2 User"
git config --global user.email "user@ec2.local"

# Generate SSH key for GitHub
echo "🔑 Generating SSH key for GitHub..."
ssh-keygen -t ed25519 -C "ec2-deploy-key" -f ~/.ssh/id_ed25519 -N ""
echo ""
echo "================================"
echo "📋 SSH Public Key (add this to GitHub):"
echo "================================"
cat ~/.ssh/id_ed25519.pub
echo ""
echo "================================"
echo "Go to: https://github.com/settings/ssh/new"
echo "Paste the key above and save"
echo "================================"
echo ""

# Verify installations
echo "✅ Verifying installations..."
echo "Docker version: $(docker --version)"
echo "kubectl version: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
echo "k3s version: $(k3s --version | head -n 1)"
echo "Git version: $(git --version)"
echo "Node version: $(node --version)"
echo "Python version: $(python3 --version)"
echo "Make version: $(make --version | head -n 1)"

echo ""
echo "✅ Setup complete! Next steps:"
echo ""
echo "1. Add the SSH key above to GitHub (Settings → SSH keys)"
echo "2. Test SSH: ssh -T git@github.com"
echo "3. Clone your repository:"
echo "   git clone git@github.com:YOUR-USERNAME/microservices-k8s-project.git"
echo "4. Deploy application:"
echo "   cd microservices-k8s-project"
echo "   make deploy"
echo ""
echo "⚠️  IMPORTANT: Log out and back in for Docker group changes to take effect!"
echo "   exit"
echo "   ssh -i your-key.pem ubuntu@<EC2-IP>"
echo ""
