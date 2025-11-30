# 🧪 Testing Guide

Complete guide for testing your microservices application.

## Table of Contents
- [Quick Start](#quick-start)
- [Test Types](#test-types)
- [Running Tests](#running-tests)
- [Understanding Test Results](#understanding-test-results)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### Run All Tests (Recommended)

**Windows:**
```cmd
test-all.bat
```

**Linux/Mac:**
```bash
chmod +x test-all.sh
./test-all.sh
```

**Or using Make:**
```bash
make test-all
```

---

## Test Types

### 1. System Tests (`test-all.bat` / `test-all.sh`)

Tests your complete environment setup:
- ✅ Docker installation and daemon
- ✅ kubectl installation
- ✅ Python and Node.js versions
- ✅ Git installation
- ✅ Project file structure
- ✅ Kubernetes YAML validity
- ✅ Docker Compose configuration
- ✅ Backend unit tests

**When to run:** Before deployment or after environment changes

### 2. Docker Build Tests (`test-docker-build.bat` / `test-docker-build.sh`)

Tests Docker image building:
- ✅ Backend image builds successfully
- ✅ Frontend image builds successfully
- ✅ No Dockerfile syntax errors

**When to run:** After modifying Dockerfiles

### 3. Backend Unit Tests

Tests Flask API without external dependencies:
- ✅ Home endpoint responds
- ✅ Health check endpoint works
- ✅ Metrics endpoint is accessible

**When to run:** After modifying backend code

### 4. Frontend Unit Tests

Tests React components:
- ✅ App component renders
- ✅ Task manager header is present

**When to run:** After modifying frontend code

---

## Running Tests

### All Tests

```bash
# Comprehensive system test
make test-all

# Or directly
test-all.bat          # Windows
./test-all.sh         # Linux/Mac
```

**Output:**
```
[1/10] Testing Docker installation...
[PASS] Docker is installed

[2/10] Testing Docker daemon...
[PASS] Docker daemon is running

[3/10] Testing kubectl installation...
[PASS] kubectl is installed

...

TEST SUMMARY
Tests Passed:   8
Tests Failed:   0
Warnings:       2
```

### Backend Tests Only

```bash
# Using Make
make test-backend

# Or directly
cd backend
python -m pytest -v
```

**Expected output:**
```
============================= test session starts =============================
test_app.py::test_home PASSED                                            [ 33%]
test_app.py::test_health_endpoint PASSED                                 [ 66%]
test_app.py::test_metrics_endpoint PASSED                                [100%]

============================== 3 passed in 0.45s ==============================
```

### Frontend Tests Only

```bash
# Using Make
make test-frontend

# Or directly
cd frontend
npm test -- --watchAll=false
```

**Expected output:**
```
PASS src/App.test.js
  ✓ renders task manager header (45 ms)

Test Suites: 1 passed, 1 total
Tests:       1 passed, 1 total
```

### Docker Build Tests

```bash
# Using Make
make test-docker

# Or directly
test-docker-build.bat    # Windows
./test-docker-build.sh   # Linux/Mac
```

**Expected output:**
```
[1/2] Testing backend Docker build...
[PASS] Backend Docker image built successfully

[2/2] Testing frontend Docker build...
[PASS] Frontend Docker image built successfully
```

### Integration Tests (Running System)

Test the deployed application:

```bash
# 1. Deploy the application
make deploy

# 2. Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=backend --timeout=300s

# 3. Test the endpoints
curl http://localhost:30080                # Frontend
curl http://localhost:30080/health         # Backend health
curl http://localhost:30090/metrics        # Prometheus
```

---

## Understanding Test Results

### Test Status Indicators

- **[PASS]** ✅ - Test passed successfully
- **[FAIL]** ❌ - Test failed, action required
- **[WARN]** ⚠️ - Warning, may need attention
- **[SKIP]** ⏭️ - Test skipped (dependency missing)

### Common Test Outputs

#### ✅ All Tests Pass
```
========================================
 TEST SUMMARY
========================================

Tests Passed:   10
Tests Failed:   0
Warnings:       0

Ready to deploy!
```
**Action:** You're good to go! Deploy with `make deploy`

#### ⚠️ Some Warnings
```
Tests Passed:   8
Tests Failed:   0
Warnings:       2

[WARN] kubectl is not installed
[WARN] Git is not installed
```
**Action:** Warnings are okay for local testing, but install missing tools for full functionality

#### ❌ Test Failures
```
Tests Passed:   6
Tests Failed:   2
Warnings:       2

[FAIL] Docker daemon is not running
[FAIL] Backend Docker build failed
```
**Action:** Fix failed tests before deploying (see Troubleshooting)

---

## Test Scenarios

### Scenario 1: First-Time Setup

**Goal:** Verify environment is ready

```bash
# Run system tests
make test-all
```

**Look for:**
- Docker installed and running
- Python and Node.js installed
- All project files present
- YAML files valid

### Scenario 2: Before Deployment

**Goal:** Ensure everything builds correctly

```bash
# Test Docker builds
make test-docker

# Test code
make test-backend
make test-frontend
```

**Look for:**
- Both images build successfully
- All unit tests pass

### Scenario 3: After Code Changes

**Goal:** Verify changes didn't break anything

```bash
# Test affected component
make test-backend    # If backend changed
make test-frontend   # If frontend changed

# Test Docker build
make test-docker
```

### Scenario 4: Deployment Verification

**Goal:** Verify running system

```bash
# Check pod status
kubectl get pods

# Test endpoints
curl http://localhost:30080/health

# Check logs
kubectl logs -l app=backend --tail=20
```

---

## Troubleshooting

### Docker Not Running

**Error:**
```
[FAIL] Docker daemon is not running
```

**Fix:**
1. Start Docker Desktop
2. Wait for it to fully start (Docker icon in system tray)
3. Run tests again

### Backend Tests Fail

**Error:**
```
[WARN] Backend tests failed or could not run
```

**Common causes:**
1. Database/Redis not running (expected in unit tests)
2. Missing pytest: `pip install pytest requests`
3. Wrong Python version: Need Python 3.8+

**Fix:**
```bash
cd backend
pip install -r requirements.txt
python -m pytest -v
```

### Frontend Tests Fail

**Error:**
```
Test suite failed to run
```

**Common causes:**
1. Missing dependencies
2. Node.js version too old

**Fix:**
```bash
cd frontend
npm install
npm test -- --watchAll=false
```

### Docker Build Fails

**Error:**
```
[FAIL] Backend Docker build failed
```

**Fix:**
1. Check Dockerfile syntax
2. Ensure requirements.txt is correct
3. Try building manually for detailed errors:
```bash
cd backend
docker build -t test-backend .
```

### kubectl Not Found

**Error:**
```
[WARN] kubectl is not installed
```

**Fix:**
Install kubectl:
- **Windows:** `choco install kubernetes-cli`
- **Mac:** `brew install kubectl`
- **Linux:** [Official guide](https://kubernetes.io/docs/tasks/tools/)

### YAML Validation Fails

**Error:**
```
[FAIL] Invalid YAML: k8s/backend-deployment.yaml
```

**Fix:**
1. Check YAML syntax (indentation must be exact)
2. Validate manually:
```bash
kubectl apply --dry-run=client -f k8s/backend-deployment.yaml
```

---

## Advanced Testing

### Load Testing

Test application under load:

```bash
# Install Apache Bench
apt-get install apache2-utils  # Linux
brew install ab                 # Mac

# Run load test
ab -n 1000 -c 10 http://localhost:30080/api/tasks
```

### Performance Testing

Monitor performance metrics:

```bash
# Deploy with monitoring
make deploy

# Access Grafana
# http://localhost:30300
# Username: admin
# Password: admin123

# Check metrics
curl http://localhost:30090/metrics
```

### Security Testing

Check for vulnerabilities:

```bash
# Scan Docker images
docker scan backend:latest
docker scan frontend:latest

# Check Kubernetes security
kubectl auth can-i --list
```

---

## CI/CD Testing

Tests run automatically in GitHub Actions:

### Workflow Stages

1. **Test Stage**
   - Backend: `pytest`
   - Frontend: `npm test`

2. **Build Stage**
   - Docker images build
   - Push to registry

3. **Deploy Stage**
   - kubectl apply
   - Rollout verification

### View CI/CD Results

1. Go to your GitHub repository
2. Click "Actions" tab
3. View workflow runs and logs

---

## Test Coverage

### Backend Coverage

Check test coverage:

```bash
cd backend
pip install pytest-cov
pytest --cov=app --cov-report=html
open htmlcov/index.html  # View coverage report
```

### Frontend Coverage

Check test coverage:

```bash
cd frontend
npm test -- --coverage --watchAll=false
```

---

## Quick Reference

### Test Commands

| Command | Description | Time |
|---------|-------------|------|
| `make test-all` | Comprehensive system tests | ~2 min |
| `make test-backend` | Backend unit tests | ~5 sec |
| `make test-frontend` | Frontend unit tests | ~10 sec |
| `make test-docker` | Docker build tests | ~3 min |
| `test-all.bat` | Full system test (Windows) | ~2 min |
| `./test-all.sh` | Full system test (Linux/Mac) | ~2 min |

### Test Files

| File | Purpose |
|------|---------|
| `test-all.bat` | Windows system tests |
| `test-all.sh` | Linux/Mac system tests |
| `test-docker-build.bat` | Windows Docker tests |
| `test-docker-build.sh` | Linux/Mac Docker tests |
| `backend/test_app.py` | Backend unit tests |
| `frontend/src/App.test.js` | Frontend unit tests |

---

## Pre-Deployment Checklist

Before deploying to production:

- [ ] All system tests pass (`make test-all`)
- [ ] Docker builds succeed (`make test-docker`)
- [ ] Backend tests pass (`make test-backend`)
- [ ] Frontend tests pass (`make test-frontend`)
- [ ] YAML files are valid
- [ ] Docker daemon is running
- [ ] kubectl is configured
- [ ] No security warnings

**Ready to deploy!**

```bash
make deploy
```

---

## Need Help?

### Common Issues
1. Check [Troubleshooting](#troubleshooting) section
2. Review [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md)
3. Check logs: `kubectl logs -l app=backend`

### Resources
- [README.md](README.md) - Main documentation
- [QUICKSTART.md](QUICKSTART.md) - Quick reference
- [ARCHITECTURE.md](ARCHITECTURE.md) - System design

---

**Happy Testing!** 🧪✅
