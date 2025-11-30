# GitHub Setup and Integration Guide

Complete guide to push your microservices project to GitHub and set up CI/CD automation.

## Prerequisites

- Git installed on your local machine
- GitHub account (free tier is sufficient)

## Step 1: Create GitHub Repository

### 1.1 Via GitHub Website

1. Go to [GitHub.com](https://github.com)
2. Log in to your account
3. Click the **+** icon in top right → **New repository**

4. Configure repository:
   ```
   Repository name: microservices-k8s-project
   Description: Production microservices app with React, Flask, K8s, Prometheus & Grafana
   Visibility: Public (or Private)
   
   ❌ Do NOT initialize with README (we already have one)
   ❌ Do NOT add .gitignore (we already have one)
   ❌ Do NOT add license yet
   ```

5. Click **Create repository**

You'll see a page with setup instructions. Keep this open.

## Step 2: Initialize Local Git Repository

### 2.1 Open Terminal in Project Directory

```bash
cd C:\Users\mohaa\OneDrive\Skrivebord\microservices-k8s-project
```

### 2.2 Initialize Git (if not already done)

```bash
# Check if git is already initialized
git status

# If not, initialize
git init

# Configure your identity (if not done globally)
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 2.3 Check Current Status

```bash
git status
```

You should see all your project files listed as untracked.

## Step 3: Add Files to Git

### 3.1 Review .gitignore

The `.gitignore` file is already configured to exclude:
- `node_modules/`
- `__pycache__/`
- `.env` files
- IDE settings
- Build artifacts

### 3.2 Add All Files

```bash
# Add all files
git add .

# Verify files staged
git status
```

You should see all files in green (staged for commit).

### 3.3 Make Initial Commit

```bash
git commit -m "Initial commit: Production microservices app with K8s, monitoring, and CI/CD"
```

## Step 4: Push to GitHub

### 4.1 Add Remote Repository

Replace `YOUR_USERNAME` with your GitHub username:

```bash
git remote add origin https://github.com/YOUR_USERNAME/microservices-k8s-project.git

# Example:
# git remote add origin https://github.com/johndoe/microservices-k8s-project.git
```

### 4.2 Verify Remote

```bash
git remote -v
```

Should show:
```
origin  https://github.com/YOUR_USERNAME/microservices-k8s-project.git (fetch)
origin  https://github.com/YOUR_USERNAME/microservices-k8s-project.git (push)
```

### 4.3 Push to GitHub

```bash
# Push to main branch
git push -u origin main
```

**If you get an authentication error:**

#### Option A: Use Personal Access Token (Recommended)

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click **Generate new token** → **Generate new token (classic)**
3. Configure:
   ```
   Note: Microservices K8s Project
   Expiration: 90 days (or custom)
   Scopes:
   ✅ repo (Full control of private repositories)
   ✅ workflow (Update GitHub Actions workflows)
   ```
4. Click **Generate token**
5. **Copy the token** (you won't see it again!)
6. Use this token as password when pushing:
   ```bash
   Username: your-github-username
   Password: ghp_your_personal_access_token
   ```

#### Option B: Use SSH Key

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Copy public key
cat ~/.ssh/id_ed25519.pub

# Add to GitHub:
# Settings → SSH and GPG keys → New SSH key

# Change remote to SSH
git remote set-url origin git@github.com:YOUR_USERNAME/microservices-k8s-project.git

# Push
git push -u origin main
```

## Step 5: Verify on GitHub

1. Go to your GitHub repository page
2. Refresh the page
3. You should see all your project files!

Repository structure should show:
```
.github/
.gitignore
ARCHITECTURE.md
AWS_EC2_DEPLOYMENT.md
backend/
DEPLOYMENT_CHECKLIST.md
docker-compose.yml
frontend/
GITHUB_SETUP.md
k8s/
Makefile
PROJECT_SUMMARY.md
QUICKSTART.md
README.md
scripts/
```

## Step 6: Set Up Repository Secrets (for CI/CD)

To enable automated deployment, add these secrets:

### 6.1 Navigate to Repository Settings

1. Go to your repository on GitHub
2. Click **Settings** tab
3. Click **Secrets and variables** → **Actions**
4. Click **New repository secret**

### 6.2 Add KUBECONFIG Secret

If you have a Kubernetes cluster (like on EC2):

1. On your EC2 instance (or local k8s):
   ```bash
   # Get kubeconfig content
   cat ~/.kube/config | base64 -w 0
   ```

2. Create secret on GitHub:
   ```
   Name: KUBECONFIG
   Value: <paste the base64 encoded kubeconfig>
   ```

### 6.3 Add Docker Registry Secrets (Optional)

If using Docker Hub or GitHub Container Registry:

```
Name: DOCKER_USERNAME
Value: your-dockerhub-username

Name: DOCKER_PASSWORD
Value: your-dockerhub-token
```

## Step 7: Update GitHub Actions Workflow

The CI/CD pipeline is already configured in `.github/workflows/ci-cd.yml`.

### 7.1 Review Workflow File

The workflow does:
1. **Test** - Run backend and frontend tests
2. **Build** - Build Docker images
3. **Push** - Push to GitHub Container Registry
4. **Deploy** - Deploy to Kubernetes (if secrets configured)

### 7.2 Customize for Your Setup

If you want to use GitHub Container Registry:

```bash
# No changes needed! It's already configured to use ghcr.io
```

If you want to use Docker Hub instead:

Edit `.github/workflows/ci-cd.yml`:
```yaml
env:
  REGISTRY: docker.io
  BACKEND_IMAGE: your-username/backend
  FRONTEND_IMAGE: your-username/frontend
```

## Step 8: Test CI/CD Pipeline

### 8.1 Make a Small Change

```bash
# Edit a file (e.g., README.md)
echo "" >> README.md

# Commit and push
git add README.md
git commit -m "Test CI/CD pipeline"
git push origin main
```

### 8.2 Watch the Pipeline

1. Go to your repository on GitHub
2. Click **Actions** tab
3. You should see your workflow running!

The pipeline will:
- ✅ Run tests
- ✅ Build images (if on main branch)
- ✅ Deploy (if KUBECONFIG secret is set)

## Step 9: Enable GitHub Pages (Optional)

Host your documentation on GitHub Pages:

1. Go to **Settings** → **Pages**
2. Source: Deploy from a branch
3. Branch: `main` / `docs` (or create a docs branch)
4. Click **Save**

Your docs will be available at:
`https://YOUR_USERNAME.github.io/microservices-k8s-project/`

## Step 10: Add Repository Badges

Make your README look professional with status badges!

### 10.1 Add CI/CD Badge

Add this to the top of your `README.md`:

```markdown
# Production Microservices Application with Kubernetes

![CI/CD Pipeline](https://github.com/YOUR_USERNAME/microservices-k8s-project/workflows/CI/CD%20Pipeline/badge.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Kubernetes](https://img.shields.io/badge/kubernetes-v1.25+-blue.svg)
![Docker](https://img.shields.io/badge/docker-20.10+-blue.svg)
```

## Common Git Workflows

### Making Changes

```bash
# 1. Make your changes to files

# 2. Check what changed
git status
git diff

# 3. Stage changes
git add .
# Or stage specific files
git add backend/app.py frontend/src/App.js

# 4. Commit
git commit -m "Add feature: user authentication"

# 5. Push to GitHub
git push origin main
```

### Working with Branches

```bash
# Create and switch to new branch
git checkout -b feature/add-user-auth

# Make changes, commit
git add .
git commit -m "Implement user authentication"

# Push branch to GitHub
git push origin feature/add-user-auth

# On GitHub, create Pull Request

# After merging, switch back to main
git checkout main
git pull origin main
```

### Updating from EC2

When you push changes to GitHub, update your EC2 deployment:

```bash
# SSH to EC2
ssh -i microservices-k8s-key.pem ubuntu@YOUR_EC2_IP

# Navigate to project
cd microservices-k8s-project

# Pull latest changes
git pull origin main

# Rebuild and redeploy
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend
kubectl rollout restart deployment/backend
kubectl rollout restart deployment/frontend
```

## Setting Up Protected Branches

Protect your main branch from direct pushes:

1. Go to **Settings** → **Branches**
2. Click **Add rule**
3. Configure:
   ```
   Branch name pattern: main
   
   ✅ Require a pull request before merging
   ✅ Require status checks to pass before merging
   ✅ Require branches to be up to date before merging
   ```
4. Click **Create**

Now all changes must go through Pull Requests!

## Collaborating with Others

### Adding Collaborators

1. Go to **Settings** → **Collaborators**
2. Click **Add people**
3. Enter GitHub username or email
4. They'll receive an invitation

### Code Review Process

1. Create feature branch
2. Make changes and push
3. Create Pull Request
4. Request review from team member
5. Address feedback
6. Merge when approved

## Useful Git Commands

### View History

```bash
# View commit history
git log

# View compact history
git log --oneline --graph --all

# View changes in last commit
git show
```

### Undo Changes

```bash
# Undo unstaged changes
git checkout -- filename

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1

# Revert a specific commit
git revert <commit-hash>
```

### Syncing Forks

```bash
# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/repo.git

# Fetch upstream changes
git fetch upstream

# Merge upstream changes
git merge upstream/main
```

## GitHub Features to Explore

### Issues

Track bugs, features, and tasks:
- Go to **Issues** tab → **New issue**
- Add labels, assignees, milestones
- Reference issues in commits: `git commit -m "Fix login bug #123"`

### Projects

Organize work with Kanban boards:
- Go to **Projects** tab → **New project**
- Create columns: To Do, In Progress, Done
- Add issues and pull requests

### Wiki

Create documentation:
- Go to **Wiki** tab → **Create the first page**
- Write docs in Markdown

### Releases

Create versioned releases:
- Go to **Releases** tab → **Create a new release**
- Tag: v1.0.0
- Add release notes

## Troubleshooting

### Authentication Failed

**Solution:**
Use Personal Access Token instead of password.

### Permission Denied (publickey)

**Solution:**
Set up SSH key or use HTTPS instead:
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/repo.git
```

### Merge Conflicts

**Solution:**
```bash
# Update your branch
git pull origin main

# Fix conflicts in files (look for <<<<<<< markers)

# Stage resolved files
git add .

# Complete merge
git commit -m "Resolve merge conflicts"
```

### Large Files Error

**Solution:**
Use Git LFS for files >100MB:
```bash
git lfs install
git lfs track "*.psd"
git add .gitattributes
```

## Best Practices

### Commit Messages

✅ Good:
```
Add Redis caching to task endpoints
Fix database connection timeout issue
Update Grafana dashboard configuration
```

❌ Bad:
```
changes
fix
update
```

### Commit Frequency

- Commit often (logical units of work)
- Don't commit broken code
- Test before committing

### Branch Naming

```
feature/add-user-auth
bugfix/fix-login-error
hotfix/security-patch
docs/update-readme
```

### .gitignore

Keep sensitive data out:
```
.env
.env.local
*.pem
kubeconfig
secrets.yaml
```

## Integration with CI/CD

Your GitHub repository now automatically:

1. **Tests** every push
2. **Builds** Docker images on main branch
3. **Deploys** to Kubernetes (if configured)
4. **Notifies** you of build status

View pipeline results in **Actions** tab.

## Next Steps

1. ✅ Create repository on GitHub
2. ✅ Push your code
3. ✅ Set up repository secrets
4. ✅ Enable GitHub Actions
5. ✅ Add status badges
6. ✅ Invite collaborators
7. ✅ Set up branch protection
8. ✅ Create first release (v1.0.0)

## Quick Reference

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/repo.git

# Check status
git status

# Add files
git add .

# Commit
git commit -m "Your message"

# Push
git push origin main

# Pull latest
git pull origin main

# Create branch
git checkout -b feature-name

# Switch branch
git checkout main

# Merge branch
git merge feature-name

# View remotes
git remote -v

# View history
git log --oneline
```

---

## Summary

You now have:
✅ Project pushed to GitHub  
✅ CI/CD pipeline configured  
✅ Automated testing on every push  
✅ Automated deployment (if secrets configured)  
✅ Professional repository setup  
✅ Ready for collaboration  

**Your repository:** `https://github.com/YOUR_USERNAME/microservices-k8s-project` 🎉

**Next:** Follow AWS_EC2_DEPLOYMENT.md to deploy on cloud!
