.PHONY: help build deploy clean test logs status restart

# Default target
help:
	@echo "Microservices K8s Project - Make Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  make build          - Build all Docker images"
	@echo "  make deploy         - Deploy all services to Kubernetes"
	@echo "  make deploy-app     - Deploy app services only (no monitoring)"
	@echo "  make deploy-monitor - Deploy monitoring stack only"
	@echo "  make test           - Run all tests"
	@echo "  make test-all       - Run comprehensive system tests"
	@echo "  make test-backend   - Run backend tests only"
	@echo "  make test-frontend  - Run frontend tests only"
	@echo "  make test-docker    - Test Docker image builds"
	@echo "  make logs           - Tail logs from all services"
	@echo "  make status         - Check status of all pods"
	@echo "  make restart        - Restart all deployments"
	@echo "  make clean          - Remove all Kubernetes resources"
	@echo "  make dev            - Start local development environment"
	@echo "  make port-forward   - Forward ports for local access"

# Build Docker images
build:
	@echo "Building Docker images..."
	docker build -t backend:latest ./backend
	docker build -t frontend:latest ./frontend
	@echo "✓ Images built successfully"

# Deploy everything
deploy: build
	@echo "Deploying to Kubernetes..."
	kubectl apply -f k8s/postgres-deployment.yaml
	kubectl apply -f k8s/redis-deployment.yaml
	kubectl apply -f k8s/backend-deployment.yaml
	kubectl apply -f k8s/frontend-deployment.yaml
	kubectl apply -f k8s/prometheus-deployment.yaml
	kubectl apply -f k8s/grafana-deployment.yaml
	@echo "✓ All services deployed"
	@echo ""
	@make status

# Deploy app services only
deploy-app: build
	@echo "Deploying application services..."
	kubectl apply -f k8s/postgres-deployment.yaml
	kubectl apply -f k8s/redis-deployment.yaml
	kubectl apply -f k8s/backend-deployment.yaml
	kubectl apply -f k8s/frontend-deployment.yaml
	@echo "✓ Application services deployed"

# Deploy monitoring stack
deploy-monitor:
	@echo "Deploying monitoring stack..."
	kubectl apply -f k8s/prometheus-deployment.yaml
	kubectl apply -f k8s/grafana-deployment.yaml
	@echo "✓ Monitoring stack deployed"

# Run tests
test:
	@echo "Running backend tests..."
	cd backend && python -m pytest
	@echo "Running frontend tests..."
	cd frontend && npm test -- --watchAll=false
	@echo "✓ All tests passed"

# Run comprehensive system tests
test-all:
	@echo "Running comprehensive system tests..."
ifeq ($(OS),Windows_NT)
	test-all.bat
else
	chmod +x test-all.sh && ./test-all.sh
endif

# Test backend only
test-backend:
	@echo "Running backend tests..."
	cd backend && python -m pytest -v
	@echo "✓ Backend tests passed"

# Test frontend only
test-frontend:
	@echo "Running frontend tests..."
	cd frontend && npm test -- --watchAll=false --verbose
	@echo "✓ Frontend tests passed"

# Test Docker builds
test-docker:
	@echo "Testing Docker image builds..."
ifeq ($(OS),Windows_NT)
	test-docker-build.bat
else
	chmod +x test-docker-build.sh && ./test-docker-build.sh
endif

# View logs
logs:
	kubectl logs -f -l app=backend --tail=50 &
	kubectl logs -f -l app=frontend --tail=50 &
	kubectl logs -f -l app=postgres --tail=50

# Check status
status:
	@echo "Pods:"
	@kubectl get pods
	@echo ""
	@echo "Services:"
	@kubectl get services
	@echo ""
	@echo "Access URLs (if using NodePort):"
	@echo "  Frontend: http://localhost:30080"
	@echo "  Prometheus: http://localhost:30090"
	@echo "  Grafana: http://localhost:30300 (admin/admin123)"

# Restart deployments
restart:
	@echo "Restarting deployments..."
	kubectl rollout restart deployment/backend
	kubectl rollout restart deployment/frontend
	kubectl rollout restart deployment/postgres
	kubectl rollout restart deployment/redis
	@echo "✓ Deployments restarted"

# Clean all resources
clean:
	@echo "Removing all Kubernetes resources..."
	kubectl delete -f k8s/ --ignore-not-found=true
	kubectl delete namespace monitoring --ignore-not-found=true
	@echo "✓ All resources removed"

# Local development
dev:
	@echo "Starting local development..."
	docker-compose up -d
	@echo "✓ Development environment running"
	@echo "Backend: http://localhost:5000"
	@echo "Frontend: http://localhost:3000"

# Port forwarding for local access
port-forward:
	@echo "Setting up port forwarding..."
	kubectl port-forward service/frontend-service 8080:80 &
	kubectl port-forward service/backend-service 5000:5000 &
	kubectl port-forward service/prometheus-service 9090:9090 -n monitoring &
	kubectl port-forward service/grafana-service 3000:3000 -n monitoring &
	@echo "✓ Port forwarding active"
	@echo "  Frontend: http://localhost:8080"
	@echo "  Backend: http://localhost:5000"
	@echo "  Prometheus: http://localhost:9090"
	@echo "  Grafana: http://localhost:3000"
