# Production Microservices Application with Kubernetes

A complete, production-ready microservices application demonstrating modern DevOps practices with containerization, orchestration, monitoring, and CI/CD automation.

## 🚀 Quick Links

- **[Complete Setup Guide](COMPLETE_SETUP_GUIDE.md)** - Push to GitHub & Deploy to AWS EC2 in 30 minutes
- **[GitHub Setup](GITHUB_SETUP.md)** - Detailed GitHub integration guide
- **[AWS EC2 Deployment](AWS_EC2_DEPLOYMENT.md)** - Step-by-step AWS deployment
- **[Architecture](ARCHITECTURE.md)** - System design and component details
- **[Deployment Checklist](DEPLOYMENT_CHECKLIST.md)** - Verification steps

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Kubernetes Cluster                       │
│                                                                  │
│  ┌──────────────┐         ┌──────────────┐                     │
│  │   Frontend   │────────▶│   Backend    │                     │
│  │  (React +    │         │  (Flask API) │                     │
│  │   Nginx)     │         │  + Metrics   │                     │
│  │  Replicas: 2 │         │  Replicas: 2 │                     │
│  └──────┬───────┘         └──────┬───────┘                     │
│         │                        │                               │
│         │                        ├─────────────────┐            │
│         │                        │                 │            │
│         │                 ┌──────▼──────┐   ┌─────▼─────┐     │
│         │                 │  PostgreSQL │   │   Redis   │     │
│         │                 │  (Database) │   │  (Cache)  │     │
│         │                 └─────────────┘   └───────────┘     │
│         │                                                       │
│         │      ┌─────────────────────────────────┐            │
│         └─────▶│     Monitoring Namespace         │            │
│                │                                  │            │
│                │  ┌────────────┐  ┌───────────┐ │            │
│                │  │ Prometheus │──│  Grafana  │ │            │
│                │  │  (Metrics) │  │(Dashboard)│ │            │
│                │  └────────────┘  └───────────┘ │            │
│                └─────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘

External Access:
- Frontend: NodePort 30080
- Prometheus: NodePort 30090
- Grafana: NodePort 30300
```

## ✨ Features

### Application Features
- ✅ Full CRUD operations for task management
- ✅ Real-time health monitoring of all services
- ✅ Redis caching for improved performance
- ✅ PostgreSQL for persistent data storage
- ✅ Responsive React frontend
- ✅ RESTful API with Flask

### DevOps Features
- 🐳 **Containerization**: Docker containers for all services
- ☸️ **Orchestration**: Kubernetes with auto-scaling and health checks
- 📊 **Monitoring**: Prometheus metrics + Grafana dashboards
- 🔄 **CI/CD**: Automated GitHub Actions pipeline
- 🚀 **Deployment**: One-command deployment scripts
- 🧪 **Testing**: Automated unit tests for backend and frontend
- 🔐 **Secrets Management**: Kubernetes secrets for sensitive data
- 📈 **Observability**: Request tracing and performance metrics

## 🚀 Quick Start

### Prerequisites

- **Docker** (v20+)
- **Kubernetes** (minikube, Docker Desktop, or any K8s cluster)
- **kubectl** (v1.25+)
- **Node.js** (v18+) - for local development
- **Python** (v3.10+) - for local development

### Option 1: Deploy with Make (Recommended)

```bash
# Deploy everything with one command
make deploy

# Check status
make status

# View logs
make logs

# Clean up
make clean
```

### Option 2: Deploy with Scripts

**Windows:**
```cmd
scripts\deploy.bat
```

**Linux/Mac:**
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### Option 3: Manual Deployment

```bash
# Build images
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend

# Deploy to Kubernetes
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/redis-deployment.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/prometheus-deployment.yaml
kubectl apply -f k8s/grafana-deployment.yaml

# Check status
kubectl get pods
kubectl get services
```

## 🌐 Access the Application

### If using Minikube:
```bash
minikube service frontend-service
minikube service prometheus-service -n monitoring
minikube service grafana-service -n monitoring
```

### If using Docker Desktop / Other K8s:
- **Frontend**: http://localhost:30080
- **Prometheus**: http://localhost:30090
- **Grafana**: http://localhost:30300
  - Username: `admin`
  - Password: `admin123`

## 📁 Project Structure

```
microservices-k8s-project/
├── backend/                    # Flask API
│   ├── app.py                 # Main application with Redis caching
│   ├── Dockerfile             # Production container
│   ├── requirements.txt       # Python dependencies
│   └── test_app.py           # Unit tests
├── frontend/                   # React Application
│   ├── src/
│   │   ├── components/       # React components
│   │   ├── App.js           # Main app component
│   │   └── index.js         # Entry point
│   ├── public/              # Static files
│   ├── Dockerfile           # Production multi-stage build
│   ├── Dockerfile.dev       # Development container
│   ├── package.json         # Node dependencies
│   └── nginx.conf          # Nginx configuration
├── k8s/                       # Kubernetes manifests
│   ├── postgres-deployment.yaml   # Database + PVC
│   ├── redis-deployment.yaml      # Cache layer
│   ├── backend-deployment.yaml    # API service
│   ├── frontend-deployment.yaml   # Web interface
│   ├── prometheus-deployment.yaml # Metrics collection
│   └── grafana-deployment.yaml    # Monitoring dashboard
├── scripts/                   # Deployment automation
│   ├── deploy.sh             # Linux/Mac deployment
│   ├── deploy.bat            # Windows deployment
│   ├── cleanup.sh            # Linux/Mac cleanup
│   └── cleanup.bat           # Windows cleanup
├── .github/
│   └── workflows/
│       └── ci-cd.yml         # CI/CD pipeline
├── docker-compose.yml         # Local development
├── Makefile                   # Build automation
└── README.md                  # This file
```

## 📊 API Endpoints

### Application Endpoints
- `GET /` - API status check
- `GET /health` - Health check (returns DB, cache, and API status)
- `GET /api/tasks` - Get all tasks (with Redis caching)
- `POST /api/tasks` - Create a new task
- `PUT /api/tasks/<id>` - Update task status
- `DELETE /api/tasks/<id>` - Delete a task
- `POST /api/cache/clear` - Clear Redis cache

### Monitoring Endpoints
- `GET /metrics` - Prometheus metrics endpoint

## 🔧 Technology Stack

### Frontend
- **React 18** - Modern UI library
- **Axios** - HTTP client
- **React Icons** - Icon library
- **Nginx** - Production web server

### Backend
- **Flask 2.2** - Python web framework
- **PostgreSQL 15** - Relational database
- **Redis 7** - In-memory cache
- **Prometheus Client** - Metrics collection

### Infrastructure
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Prometheus** - Metrics and monitoring
- **Grafana** - Visualization and dashboards
- **GitHub Actions** - CI/CD pipeline

## 🎯 Kubernetes Resources

### Application Layer

**PostgreSQL**
- Deployment: 1 replica
- Service: ClusterIP on port 5432
- Storage: 1Gi PersistentVolumeClaim
- Secrets: Database credentials
- Resources: 256Mi-512Mi RAM

**Redis**
- Deployment: 1 replica
- Service: ClusterIP on port 6379
- Policy: LRU eviction, 256MB max memory
- Resources: 128Mi-256Mi RAM

**Backend API**
- Deployment: 2 replicas
- Service: ClusterIP on port 5000
- Health checks: Liveness + Readiness probes
- Annotations: Prometheus scraping enabled
- Resources: 128Mi-256Mi RAM per pod

**Frontend**
- Deployment: 2 replicas  
- Service: NodePort 30080
- Multi-stage build: Node build + Nginx serve
- Resources: 64Mi-128Mi RAM per pod

### Monitoring Layer

**Prometheus** (monitoring namespace)
- Deployment: 1 replica
- Service: NodePort 30090
- Retention: 7 days
- RBAC: ClusterRole for pod discovery
- Resources: 512Mi-1Gi RAM

**Grafana** (monitoring namespace)
- Deployment: 1 replica
- Service: NodePort 30300
- Pre-configured: Prometheus datasource
- Dashboards: Request metrics, latency
- Resources: 256Mi-512Mi RAM

## 🚢 Deployment Options

### Local Development with Docker Compose

```bash
# Start all services locally
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

Access:
- Frontend: http://localhost:3000 (React dev server)
- Backend: http://localhost:5000
- PostgreSQL: localhost:5432
- Redis: localhost:6379

### Production with Kubernetes

```bash
# Quick deploy
make deploy

# Or step-by-step
make build              # Build images
make deploy-app         # Deploy app only
make deploy-monitor     # Deploy monitoring
make status             # Check status
```

### Using Minikube

```bash
# Start minikube
minikube start --memory=4096 --cpus=2

# Deploy
make deploy

# Get URLs
minikube service frontend-service --url
minikube service prometheus-service -n monitoring --url
minikube service grafana-service -n monitoring --url
```

## 🧪 Testing

### Run All Tests
```bash
make test
```

### Backend Tests
```bash
cd backend
python -m pytest
python -m pytest --cov=. --cov-report=html
```

### Frontend Tests
```bash
cd frontend
npm test
npm test -- --coverage
```

## 📈 Monitoring & Observability

### Prometheus Metrics

The backend exposes custom metrics:
- `app_request_count` - Total requests by endpoint and status
- `app_request_latency_seconds` - Request duration histogram

Access Prometheus at http://localhost:30090

Example queries:
```promql
# Request rate per endpoint
rate(app_request_count[5m])

# 95th percentile latency
histogram_quantile(0.95, rate(app_request_latency_seconds_bucket[5m]))

# Cache hit ratio
rate(app_request_count{status="200_cached"}[5m]) / rate(app_request_count{status=~"200.*"}[5m])
```

### Grafana Dashboards

Access Grafana at http://localhost:30300
- Username: `admin`
- Password: `admin123`

Pre-configured dashboards show:
- Request rates and errors
- Response time percentiles
- Cache hit rates
- Pod resource usage

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline automatically:

1. **Test Stage**
   - Run backend unit tests with pytest
   - Run frontend tests with Jest
   - Generate coverage reports

2. **Build Stage** (on main branch)
   - Build Docker images
   - Tag with git SHA and branch name
   - Push to GitHub Container Registry

3. **Deploy Stage** (on main branch)
   - Deploy to Kubernetes cluster
   - Rolling update deployments
   - Wait for rollout completion

### Setup CI/CD

1. Add secrets to GitHub repository:
   - `KUBECONFIG`: Base64-encoded kubeconfig file

2. Push to main branch triggers deployment

3. View pipeline: Actions tab in GitHub

## 🛠️ Management Commands

### Scaling

```bash
# Scale backend
kubectl scale deployment backend --replicas=5

# Scale frontend
kubectl scale deployment frontend --replicas=3

# Autoscale backend
kubectl autoscale deployment backend --cpu-percent=70 --min=2 --max=10
```

### Debugging

```bash
# View logs
kubectl logs -f deployment/backend
kubectl logs -f deployment/frontend

# Describe pod
kubectl describe pod <pod-name>

# Execute commands in pod
kubectl exec -it deployment/backend -- /bin/sh

# Port forward for debugging
kubectl port-forward service/backend-service 5000:5000
```

### Database Access

```bash
# Connect to PostgreSQL
kubectl exec -it deployment/postgres -- psql -U postgres -d microservices_db

# Run SQL commands
# CREATE, SELECT, UPDATE, DELETE operations
```

### Redis Access

```bash
# Connect to Redis
kubectl exec -it deployment/redis -- redis-cli

# Check cache
KEYS *
GET tasks:all
FLUSHDB  # Clear cache
```

## 🔐 Security Considerations

- Secrets stored in Kubernetes Secrets (base64 encoded)
- Environment variables for configuration
- Network policies can be added for pod-to-pod communication
- RBAC for service accounts
- Non-root containers where possible
- Resource limits to prevent resource exhaustion

## 🚨 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods

# Describe pod for events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

### Database Connection Issues

```bash
# Check if PostgreSQL is running
kubectl get pods -l app=postgres

# Check PostgreSQL logs
kubectl logs deployment/postgres

# Verify service
kubectl get svc postgres-service
```

### Image Pull Issues

```bash
# For local development, use imagePullPolicy: Never
# Make sure images are built locally

# For minikube
minikube image load backend:latest
minikube image load frontend:latest
```

### Redis Connection Issues

```bash
# Check Redis status
kubectl exec -it deployment/redis -- redis-cli ping

# Check backend can reach Redis
kubectl exec -it deployment/backend -- ping redis-service
```

## 📚 Learning Resources

This project demonstrates:
- Microservices architecture patterns
- Container orchestration with Kubernetes
- Service discovery and load balancing
- Persistent storage with PVCs
- ConfigMaps and Secrets management
- Health checks and probes
- Horizontal pod autoscaling
- Prometheus metrics collection
- Grafana visualization
- CI/CD with GitHub Actions
- Infrastructure as Code

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

MIT License - feel free to use this project for learning and development.

## 🙋‍♂️ Support

For issues and questions:
- Open a GitHub issue
- Check the troubleshooting section
- Review Kubernetes logs

---

**Built with ❤️ for learning modern DevOps practices**
