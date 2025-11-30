# 🚀 Complete Setup Guide - GitHub & AWS EC2

This guide shows you how to push your project to GitHub and deploy it on AWS EC2 in under 30 minutes.

## 📋 Prerequisites Checklist

- [ ] GitHub account (free)
- [ ] AWS account
- [ ] Git installed locally
- [ ] SSH client (Windows: Git Bash or PowerShell)

---

## Part 1: Push to GitHub (5 minutes)

### Option A: Quick Setup with Scripts (Windows)

```cmd
# 1. Initialize git repository
scripts\git-init.bat

# 2. Create repository on GitHub
# Go to: https://github.com/new
# Name: microservices-k8s-project
# Click: Create repository

# 3. Add remote (replace YOUR_USERNAME)
git remote add origin https://github.com/YOUR_USERNAME/microservices-k8s-project.git

# 4. Push to GitHub
scripts\git-push.bat
```

### Option B: Manual Setup

```bash
# 1. Initialize git (if not already)
git init
git config user.name "Your Name"
git config user.email "your@email.com"

# 2. Add and commit files
git add .
git commit -m "Initial commit: Production microservices app"

# 3. Create GitHub repository
# Go to: https://github.com/new
# Name: microservices-k8s-project

# 4. Add remote and push
git remote add origin https://github.com/YOUR_USERNAME/microservices-k8s-project.git
git push -u origin main
```

**Authentication:**
- Use Personal Access Token (not password)
- Generate at: https://github.com/settings/tokens
- Select scopes: `repo`, `workflow`

✅ **Verify:** Check https://github.com/YOUR_USERNAME/microservices-k8s-project

---

## Part 2: Deploy on AWS EC2 (20 minutes)

### Step 1: Launch EC2 Instance (5 minutes)

1. **Go to AWS Console** → EC2 → Launch Instance

2. **Configure:**
   ```
   Name: microservices-k8s-app
   AMI: Ubuntu Server 22.04 LTS
   Instance type: t3.large (2 vCPU, 8GB RAM)
   Key pair: Create new → microservices-k8s-key.pem (Download!)
   ```

3. **Security Group:**
   ```
   Create new security group: microservices-k8s-sg
   
   Inbound rules:
   - SSH (22)        - Your IP
   - Custom TCP (30080) - 0.0.0.0/0  [Frontend]
   - Custom TCP (30090) - 0.0.0.0/0  [Prometheus]
   - Custom TCP (30300) - 0.0.0.0/0  [Grafana]
   ```

4. **Storage:** 30 GB gp3

5. **Launch Instance**

6. **Note the Public IP:** (e.g., 54.123.45.67)

### Step 2: Connect to EC2 (2 minutes)

**Windows (PowerShell or Git Bash):**
```bash
# Set key permissions
icacls microservices-k8s-key.pem /inheritance:r
icacls microservices-k8s-key.pem /grant:r "%USERNAME%:R"

# Connect
ssh -i microservices-k8s-key.pem ubuntu@YOUR_EC2_IP
```

**Mac/Linux:**
```bash
chmod 400 microservices-k8s-key.pem
ssh -i microservices-k8s-key.pem ubuntu@YOUR_EC2_IP
```

### Step 3: Setup EC2 Environment (5 minutes)

**Option A: Automated Setup (Recommended)**

```bash
# Download and run setup script
wget https://raw.githubusercontent.com/YOUR_USERNAME/microservices-k8s-project/main/scripts/ec2-setup.sh
chmod +x ec2-setup.sh
./ec2-setup.sh

# If Docker was just installed, log out and back in:
exit
ssh -i microservices-k8s-key.pem ubuntu@YOUR_EC2_IP
```

**Option B: Manual Setup**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu
# Log out and back in

# Install Kubernetes (k3s)
curl -sfL https://get.k3s.io | sh -
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown ubuntu:ubuntu ~/.kube/config

# Install Git
sudo apt install git -y
```

### Step 4: Deploy Application (8 minutes)

```bash
# 1. Clone your repository
git clone https://github.com/YOUR_USERNAME/microservices-k8s-project.git
cd microservices-k8s-project

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Deploy everything
./scripts/ec2-deploy.sh

# Or use Makefile
make deploy
```

The script will:
- ✅ Build Docker images
- ✅ Deploy PostgreSQL & Redis
- ✅ Deploy Backend & Frontend
- ✅ Deploy Prometheus & Grafana (optional)

**Wait for deployment to complete (~3-5 minutes)**

### Step 5: Access Your Application

Get your EC2 public IP:
```bash
curl http://169.254.169.254/latest/meta-data/public-ipv4
```

Open in browser:
```
Frontend:   http://YOUR_EC2_IP:30080
Prometheus: http://YOUR_EC2_IP:30090
Grafana:    http://YOUR_EC2_IP:30300
            Username: admin
            Password: admin123
```

Example:
```
http://54.123.45.67:30080
http://54.123.45.67:30090
http://54.123.45.67:30300
```

---

## 🎯 Quick Commands Reference

### Local Development (Windows)

```cmd
# Push changes to GitHub
scripts\git-push.bat

# Check status
git status

# View commit history
git log --oneline
```

### On EC2

```bash
# Update application from GitHub
./scripts/ec2-update.sh

# Check pod status
kubectl get pods

# View logs
kubectl logs -f deployment/backend

# Restart services
kubectl rollout restart deployment/backend

# Scale up
kubectl scale deployment backend --replicas=3

# Check resource usage
kubectl top pods
```

---

## 🔄 Development Workflow

### Making Changes

**1. On Your Local Machine:**
```bash
# Make code changes

# Commit and push
git add .
git commit -m "Add feature: user authentication"
git push origin main
```

**2. On EC2:**
```bash
# Update from GitHub
cd microservices-k8s-project
./scripts/ec2-update.sh
```

Done! Your changes are live.

---

## 🔧 Troubleshooting

### Cannot SSH to EC2

**Check:**
- Security group allows SSH (port 22) from your IP
- Key file has correct permissions
- Instance is running

**Solution:**
```bash
# Windows
icacls microservices-k8s-key.pem /reset

# Mac/Linux
chmod 400 microservices-k8s-key.pem
```

### Cannot Access Application

**Check:**
- Security group has ports 30080, 30090, 30300 open
- Pods are running: `kubectl get pods`
- Services exist: `kubectl get svc`

**Solution:**
```bash
# Restart deployments
kubectl rollout restart deployment --all

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### GitHub Authentication Failed

**Solution:**
Use Personal Access Token:
1. Go to: https://github.com/settings/tokens
2. Generate new token (classic)
3. Select: `repo`, `workflow`
4. Use token as password when pushing

### Pods Not Starting

**Solution:**
```bash
# Check pod details
kubectl describe pod <pod-name>

# Rebuild images
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend

# Delete and recreate
kubectl delete pod <pod-name>
```

---

## 💰 Cost Estimate

**t3.large (recommended):**
- ~$60/month (running 24/7)
- ~$2/day

**Ways to save:**
- Stop instance when not using (charges only for storage ~$3/month)
- Use t3.medium for testing (~$30/month)
- Use AWS Free Tier (t2.micro for 12 months)

**To stop instance:**
```
AWS Console → EC2 → Select instance → Instance state → Stop
```

---

## ✅ Success Checklist

### GitHub Setup
- [ ] Repository created on GitHub
- [ ] All code pushed to repository
- [ ] Can view files on GitHub website
- [ ] CI/CD pipeline running (Actions tab)

### EC2 Deployment
- [ ] EC2 instance launched and running
- [ ] Can SSH to instance
- [ ] Docker installed
- [ ] Kubernetes (k3s) installed
- [ ] Application deployed
- [ ] All pods running
- [ ] Frontend accessible in browser
- [ ] Can create/update/delete tasks
- [ ] Prometheus showing metrics
- [ ] Grafana dashboards loading

---

## 🎓 What You've Accomplished

✅ **Source Control**
- Project on GitHub with version control
- Professional repository setup
- Automated CI/CD pipeline

✅ **Cloud Deployment**
- Application running on AWS
- Production Kubernetes cluster
- Auto-healing and load balancing

✅ **Monitoring**
- Prometheus collecting metrics
- Grafana dashboards
- Health monitoring

✅ **Complete DevOps Pipeline**
- Code → GitHub → EC2
- Automated testing
- One-command updates

---

## 📚 Next Steps

### Immediate
1. Create a task in the frontend
2. Check Prometheus metrics
3. View Grafana dashboards
4. Make a code change and update

### Short Term
- [ ] Add custom domain (Route 53)
- [ ] Set up SSL/HTTPS (Let's Encrypt)
- [ ] Configure automated backups
- [ ] Add monitoring alerts

### Long Term
- [ ] Multi-region deployment
- [ ] Auto-scaling with load balancer
- [ ] CI/CD with automatic EC2 deployment
- [ ] Database replication

---

## 🆘 Getting Help

**Documentation:**
- README.md - Complete guide
- GITHUB_SETUP.md - Detailed GitHub instructions
- AWS_EC2_DEPLOYMENT.md - Detailed AWS guide
- ARCHITECTURE.md - System design

**Useful Commands:**
```bash
# View all documentation
ls *.md

# Search for help
grep -r "keyword" *.md
```

**Support Resources:**
- GitHub Issues (your repository)
- AWS Documentation
- Kubernetes Documentation

---

## 🎉 Congratulations!

You now have:
- ✅ Code on GitHub with CI/CD
- ✅ Production app on AWS EC2
- ✅ Complete monitoring setup
- ✅ Professional DevOps workflow

**Your application is live at:**
`http://YOUR_EC2_IP:30080` 🚀

**Happy coding!** 🎊
