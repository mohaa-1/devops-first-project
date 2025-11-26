#!/usr/bin/env bash
set -euo pipefail

# remote-deploy.sh
# This script runs on the EC2 instance after the repo has been extracted to DEPLOY_PATH.
# It handles Docker-based deployment with automatic container restart.

DEPLOY_PATH="${1:-/home/$(whoami)/app}"
CONTAINER_NAME="devops-app"
IMAGE_NAME="devops-app:latest"

echo "Remote deploy starting. DEPLOY_PATH=$DEPLOY_PATH"
cd "$DEPLOY_PATH"

echo "Contents of $DEPLOY_PATH:"
ls -la

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: Docker is not installed on this EC2 instance."
  echo "Install Docker first: sudo apt-get install -y docker.io (or use yum for Amazon Linux)"
  exit 1
fi

# Stop and remove existing container if running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Stopping and removing existing container: $CONTAINER_NAME"
  docker stop "$CONTAINER_NAME" || true
  docker rm "$CONTAINER_NAME" || true
fi

# Build the Docker image
echo "Building Docker image: $IMAGE_NAME"
docker build -f .vscode/Dockerfile -t "$IMAGE_NAME" .

# Run the container
echo "Starting container: $CONTAINER_NAME"
docker run -d \
  --name "$CONTAINER_NAME" \
  -p 5000:5000 \
  --restart=unless-stopped \
  "$IMAGE_NAME"

echo "Container started successfully. Access the app at http://localhost:5000"
docker ps -a --filter "name=$CONTAINER_NAME"

echo "Remote deploy script finished."
