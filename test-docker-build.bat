@echo off
REM Test Docker image builds

echo ========================================
echo  DOCKER BUILD TEST
echo ========================================
echo.

echo [1/2] Testing backend Docker build...
cd backend
docker build -t test-backend:test . >nul 2>&1
if %errorlevel% neq 0 (
    echo [FAIL] Backend Docker build failed
    echo Running with verbose output:
    docker build -t test-backend:test .
) else (
    echo [PASS] Backend Docker image built successfully
    docker images test-backend:test
    docker rmi test-backend:test >nul 2>&1
)
cd ..
echo.

echo [2/2] Testing frontend Docker build...
cd frontend
docker build -t test-frontend:test . >nul 2>&1
if %errorlevel% neq 0 (
    echo [FAIL] Frontend Docker build failed
    echo Running with verbose output:
    docker build -t test-frontend:test .
) else (
    echo [PASS] Frontend Docker image built successfully
    docker images test-frontend:test
    docker rmi test-frontend:test >nul 2>&1
)
cd ..
echo.

echo ========================================
echo  BUILD TEST COMPLETE
echo ========================================
echo.
pause
