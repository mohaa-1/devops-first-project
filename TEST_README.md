# 🧪 Quick Test Reference

## Run Tests Now

### Option 1: Quick System Test (2 minutes)
```cmd
test-all.bat
```

### Option 2: Individual Tests

**Test Environment:**
```cmd
docker --version
kubectl version --client
python --version
node --version
```

**Test Backend:**
```cmd
cd backend
python -m pytest -v
cd ..
```

**Test Docker Builds:**
```cmd
test-docker-build.bat
```

## What Gets Tested

✅ Docker installation and daemon  
✅ Python, Node.js, kubectl, Git  
✅ Project file structure  
✅ Kubernetes YAML validity  
✅ Backend unit tests  
✅ Docker image builds  

## Expected Results

### ✅ Success
```
TEST SUMMARY
Tests Passed:   8+
Tests Failed:   0
Warnings:       0-2

Ready to deploy!
```

### ⚠️ With Warnings (OK)
```
[PASS] Docker is installed
[PASS] Python is installed
[WARN] kubectl is not installed
[WARN] Git is not installed
```
**Action:** Install missing tools for full features

### ❌ Failures (Fix Required)
```
[FAIL] Docker daemon is not running
```
**Action:** Start Docker Desktop

## Quick Fixes

| Issue | Fix |
|-------|-----|
| Docker not running | Start Docker Desktop |
| pytest not found | `pip install pytest` |
| npm test fails | `cd frontend && npm install` |
| YAML invalid | Check indentation |

## After Tests Pass

```bash
# Deploy everything
make deploy

# Or step by step
make build
make deploy-app
make status
```

## Files Created

- ✅ `test-all.bat` - Comprehensive Windows tests
- ✅ `test-all.sh` - Comprehensive Linux/Mac tests  
- ✅ `test-docker-build.bat` - Docker build tests (Windows)
- ✅ `test-docker-build.sh` - Docker build tests (Linux/Mac)
- ✅ `TESTING_GUIDE.md` - Detailed testing documentation

## More Info

📖 Read: [TESTING_GUIDE.md](TESTING_GUIDE.md) for complete guide

---

**Ready to test?** Run: `test-all.bat` 🚀
