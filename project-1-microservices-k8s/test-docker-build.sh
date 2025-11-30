#!/bin/bash
# Test Docker image builds

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "========================================"
echo " DOCKER BUILD TEST"
echo "========================================"
echo

echo "[1/2] Testing backend Docker build..."
cd backend
if docker build -t test-backend:test . &> /dev/null; then
    echo -e "${GREEN}[PASS]${NC} Backend Docker image built successfully"
    docker images test-backend:test
    docker rmi test-backend:test &> /dev/null
else
    echo -e "${RED}[FAIL]${NC} Backend Docker build failed"
    echo "Running with verbose output:"
    docker build -t test-backend:test .
fi
cd ..
echo

echo "[2/2] Testing frontend Docker build..."
cd frontend
if docker build -t test-frontend:test . &> /dev/null; then
    echo -e "${GREEN}[PASS]${NC} Frontend Docker image built successfully"
    docker images test-frontend:test
    docker rmi test-frontend:test &> /dev/null
else
    echo -e "${RED}[FAIL]${NC} Frontend Docker build failed"
    echo "Running with verbose output:"
    docker build -t test-frontend:test .
fi
cd ..
echo

echo "========================================"
echo " BUILD TEST COMPLETE"
echo "========================================"
echo
