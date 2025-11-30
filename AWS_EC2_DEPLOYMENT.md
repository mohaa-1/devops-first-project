# AWS EC2 Deployment Guide

Complete guide to deploy the microservices application on AWS EC2 with Kubernetes.

## Prerequisites

- AWS Account with EC2 access
- SSH key pair created in AWS
- Basic knowledge of AWS console

## Architecture on AWS

```
┌─────────────────────────────────────────────┐
│            AWS Cloud (Your Region)          │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │         VPC (Virtual Network)         │  │
│  │                                       │  │
│  │  ┌─────────────────────────────────┐ │  │
│  │  │   Security Group (Firewall)     │ │  │
│  │  │   - Port 22 (SSH)               │ │  │
│  │  │   - Port 30080 (Frontend)       │ │  │
│  │  │   - Port 30090 (Prometheus)     │ │  │
│  │  │   - Port 30300 (Grafana)        │ │  │
│  │  └─────────────────────────────────┘ │  │
│  │                                       │  │
│  │  ┌─────────────────────────────────┐ │  │
│  │  │      EC2 Instance (t3.large)    │ │  │
│  │  │                                 │ │  │
│  │  │  - Ubuntu 22.04 LTS             │ │  │
│  │  │  - Docker                       │ │  │
│  │  │  - Kubernetes (k3s)             │ │  │
│  │  │  - 4 vCPU, 8GB RAM             │ │  │
│  │  │  - 30GB Storage                 │ │  │
│  │  │                                 │ │  │
│  │  │  Your Microservices:            │ │  │
│  │  │  - Frontend                     │ │  │
│  │  │  - Backend + Redis              │ │  │
│  │  │  - PostgreSQL                   │ │  │
│  │  │  - Prometheus + Grafana         │ │  │
│  │  └─────────────────────────────────┘ │  │
│  └───────────────────────────────────────┘  │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │    Elastic IP (Static Public IP)     │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## Step 1: Launch EC2 Instance

### 1.1 Go to AWS EC2 Console

1. Log in to AWS Console
2. Navigate to **EC2** service
3. Click **Launch Instance**

### 1.2 Configure Instance

**Name and tags:**
```
Name: microservices-k8s-app
```

**Application and OS Images (AMI):**
```
Ubuntu Server 22.04 LTS (HVM), SSD Volume Type
Architecture: 64-bit (x86)
```

**Instance type:**
```
t3.large (Recommended)
- 2 vCPUs
- 8 GB RAM
- Moderate network performance

Minimum: t3.medium (2 vCPU, 4GB RAM)
```

**Key pair (login):**
```
Create new key pair:
- Name: microservices-k8s-key
- Type: RSA
- Format: .pem (for SSH)

Download and save the key file!
```

**Network settings:**
```
Create security group:
- Name: microservices-k8s-sg
- Description: Security group for microservices app

Inbound rules:
1. SSH        - Port 22    - Your IP (or 0.0.0.0/0 for testing)
2. Custom TCP - Port 30080 - 0.0.0.0/0 (Frontend)
3. Custom TCP - Port 30090 - 0.0.0.0/0 (Prometheus)
4. Custom TCP - Port 30300 - 0.0.0.0/0 (Grafana)
5. Custom TCP - Port 6443  - Your IP (Kubernetes API)
```

**Configure storage:**
```
30 GiB gp3 (SSD)
```

**Advanced details:**
```
Leave as default
```

### 1.3 Launch Instance

1. Review all settings
2. Click **Launch instance**
3. Wait for instance to be in **Running** state
4. Note the **Public IPv4 address**

### 1.4 Set up Elastic IP (Optional but Recommended)

This gives you a static IP that won't change if you restart the instance.

1. Go to **Elastic IPs** in EC2 console
2. Click **Allocate Elastic IP address**
3. Click **Allocate**
4. Select the new Elastic IP
5. Click **Actions** → **Associate Elastic IP address**
6. Select your instance
7. Click **Associate**

## Step 2: Connect to EC2 Instance

### 2.1 Set Key Permissions (Windows)

```cmd
# In PowerShell or Git Bash
icacls microservices-k8s-key.pem /inheritance:r
icacls microservices-k8s-key.pem /grant:r "%USERNAME%:R"
```

### 2.2 SSH to Instance

```bash
# Replace with your instance public IP
ssh -i microservices-k8s-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Example:
ssh -i microservices-k8s-key.pem ubuntu@54.123.45.67
```

You should see:
```
Welcome to Ubuntu 22.04 LTS
ubuntu@ip-xxx-xxx-xxx-xxx:~$
```

## Step 3: Install Prerequisites on EC2

### 3.1 Update System

```bash
sudo apt update && sudo apt upgrade -y
```

### 3.2 Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker ubuntu

# Log out and back in for group changes
exit
# SSH back in
ssh -i microservices-k8s-key.pem ubuntu@YOUR_EC2_PUBLIC_IP

# Verify Docker
docker --version
docker ps
```

### 3.3 Install Kubernetes (k3s)

k3s is a lightweight Kubernetes perfect for single-node setups:

```bash
# Install k3s
curl -sfL https://get.k3s.io | sh -

# Wait for k3s to start
sudo systemctl status k3s

# Set up kubectl access
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config

# Verify Kubernetes
kubectl cluster-info
kubectl get nodes
```

You should see one node in Ready state.

### 3.4 Install Git

```bash
sudo apt install git -y
git --version
```

### 3.5 Install Make (Optional)

```bash
sudo apt install make -y
```

## Step 4: Clone Your Repository

### 4.1 Generate SSH Key for GitHub (if needed)

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"
# Press Enter for all prompts (default location, no passphrase)

# Display the public key
cat ~/.ssh/id_ed25519.pub
```

Copy the output and add it to GitHub:
1. Go to GitHub → Settings → SSH and GPG keys
2. Click **New SSH key**
3. Paste the key
4. Click **Add SSH key**

### 4.2 Clone Repository

```bash
# Using HTTPS (easier)
git clone https://github.com/YOUR_USERNAME/microservices-k8s-project.git

# Or using SSH (if you set up SSH key)
git clone git@github.com:YOUR_USERNAME/microservices-k8s-project.git

# Navigate to project
cd microservices-k8s-project
```

## Step 5: Deploy Application

### 5.1 Build Docker Images

```bash
# Build backend
docker build -t backend:latest ./backend

# Build frontend
docker build -t frontend:latest ./frontend

# Verify images
docker images
```

### 5.2 Deploy to Kubernetes

```bash
# Deploy database and cache
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/redis-deployment.yaml

# Wait for them to be ready
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s

# Deploy application
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

# Wait for application
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend --timeout=120s

# Deploy monitoring
kubectl apply -f k8s/prometheus-deployment.yaml
kubectl apply -f k8s/grafana-deployment.yaml

# Check all pods
kubectl get pods --all-namespaces
```

### 5.3 Verify Deployment

```bash
# Check pods status
kubectl get pods

# Check services
kubectl get services

# Check logs
kubectl logs -l app=backend --tail=50
```

All pods should show **Running** status.

## Step 6: Access the Application

### 6.1 Get EC2 Public IP

```bash
# From EC2 console or:
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

### 6.2 Access URLs

Replace `YOUR_EC2_IP` with your instance's public IP:

- **Frontend**: `http://YOUR_EC2_IP:30080`
- **Prometheus**: `http://YOUR_EC2_IP:30090`
- **Grafana**: `http://YOUR_EC2_IP:30300`
  - Username: `admin`
  - Password: `admin123`

Example:
- Frontend: `http://54.123.45.67:30080`
- Prometheus: `http://54.123.45.67:30090`
- Grafana: `http://54.123.45.67:30300`

## Step 7: Set Up Continuous Deployment

### 7.1 Create Deployment Script

```bash
# Create update script
cat > ~/update-app.sh << 'EOF'
#!/bin/bash
cd ~/microservices-k8s-project

# Pull latest changes
git pull origin main

# Rebuild images
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend

# Restart deployments
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend

# Wait for rollout
kubectl rollout status deployment/backend
kubectl rollout status deployment/frontend

echo "✅ Deployment updated successfully!"
EOF

# Make executable
chmod +x ~/update-app.sh
```

### 7.2 Update Application

```bash
# Run update script whenever you push to GitHub
~/update-app.sh
```

## Monitoring and Maintenance

### Check Application Health

```bash
# View all resources
kubectl get all --all-namespaces

# Check pod logs
kubectl logs -f deployment/backend
kubectl logs -f deployment/frontend

# Check pod status
kubectl describe pod <pod-name>

# Check resource usage
kubectl top pods
kubectl top nodes
```

### Restart Services

```bash
# Restart specific deployment
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend

# Restart all
kubectl rollout restart deployment --all
```

### Scale Services

```bash
# Scale backend
kubectl scale deployment backend --replicas=3

# Scale frontend
kubectl scale deployment frontend --replicas=2
```

### View Logs

```bash
# Backend logs
kubectl logs -f -l app=backend --tail=100

# Frontend logs
kubectl logs -f -l app=frontend --tail=100

# Database logs
kubectl logs -f deployment/postgres --tail=50
```

## Troubleshooting

### Issue: Cannot SSH to Instance

**Solution:**
1. Check security group allows SSH (port 22) from your IP
2. Verify key permissions: `chmod 400 microservices-k8s-key.pem`
3. Check instance is running in EC2 console

### Issue: Cannot Access Application

**Solution:**
1. Check security group has ports 30080, 30090, 30300 open
2. Verify pods are running: `kubectl get pods`
3. Check service: `kubectl get svc frontend-service`
4. Check firewall: `sudo ufw status` (should be inactive)

### Issue: Pods Not Starting

**Solution:**
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check if images built
docker images

# Rebuild images if needed
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend
```

### Issue: Out of Memory

**Solution:**
1. Upgrade to larger instance type (t3.large → t3.xlarge)
2. Reduce number of replicas
3. Add swap space:
```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Issue: Images Not Found

**Solution:**
k3s looks for images locally first. Make sure to build them:
```bash
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend
docker images  # Verify they exist
```

## Cost Optimization

### Stop Instance When Not Using

```bash
# From AWS Console:
# Select instance → Instance state → Stop

# Restart when needed:
# Select instance → Instance state → Start
```

**Note:** If using Elastic IP, you won't be charged when instance is stopped.

### Use Spot Instances

For development/testing, use Spot Instances to save up to 90% on costs.

### Clean Up Resources

```bash
# Remove all Kubernetes resources
kubectl delete -f k8s/ --ignore-not-found=true
kubectl delete namespace monitoring --ignore-not-found=true

# Remove Docker images
docker system prune -a
```

## Security Best Practices

### 1. Restrict SSH Access

Update security group to allow SSH only from your IP:
```
SSH - Port 22 - YOUR_PUBLIC_IP/32
```

### 2. Use Strong Passwords

Change default Grafana password:
```bash
kubectl exec -it deployment/grafana -n monitoring -- grafana-cli admin reset-admin-password NEW_STRONG_PASSWORD
```

### 3. Update Regularly

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Update k3s
curl -sfL https://get.k3s.io | sh -
```

### 4. Enable HTTPS

For production, set up SSL certificates:
- Use AWS Certificate Manager
- Configure Application Load Balancer
- Or use Let's Encrypt with cert-manager

## Backup and Recovery

### Backup Database

```bash
# Export database
kubectl exec -it deployment/postgres -- pg_dump -U postgres microservices_db > backup.sql

# Restore database
cat backup.sql | kubectl exec -i deployment/postgres -- psql -U postgres microservices_db
```

### Backup Configurations

```bash
# Export all configurations
kubectl get all --all-namespaces -o yaml > k8s-backup.yaml
```

## Next Steps

1. ✅ Set up custom domain name
2. ✅ Configure SSL/HTTPS
3. ✅ Set up automated backups
4. ✅ Configure CloudWatch monitoring
5. ✅ Set up Auto Scaling Group
6. ✅ Implement CI/CD with GitHub Actions
7. ✅ Set up application load balancer

## Estimated Costs

**Monthly cost for t3.large instance (us-east-1):**
- EC2 Instance: ~$60/month (24/7 running)
- Storage (30GB): ~$3/month
- Elastic IP: Free (if attached to running instance)
- Data transfer: Minimal for development

**Total: ~$63/month**

**Tips to reduce costs:**
- Stop instance when not using (~$3/month for storage only)
- Use t3.medium for testing (~$30/month)
- Use Reserved Instances for production (~40% savings)

---

## Summary

You now have:
✅ EC2 instance running on AWS  
✅ Kubernetes cluster (k3s) installed  
✅ Microservices application deployed  
✅ Monitoring with Prometheus and Grafana  
✅ Public access to all services  
✅ Ready for continuous deployment  

**Access your application at:**
`http://YOUR_EC2_IP:30080` 🚀
