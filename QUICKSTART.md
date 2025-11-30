# Microservices K8s Project

Production-ready microservices application with Kubernetes, monitoring, and CI/CD.

## Quick Start

```bash
# Deploy everything
make deploy

# Check status
make status

# Clean up
make clean
```

## Access URLs

- **Frontend**: http://localhost:30080
- **Prometheus**: http://localhost:30090
- **Grafana**: http://localhost:30300 (admin/admin123)

## Architecture

- **Frontend**: React + Nginx (2 replicas)
- **Backend**: Flask API + Redis caching (2 replicas)
- **Database**: PostgreSQL with persistent storage
- **Cache**: Redis
- **Monitoring**: Prometheus + Grafana
- **CI/CD**: GitHub Actions

## Features

✅ React frontend with modern UI  
✅ Flask REST API with Redis caching  
✅ PostgreSQL database with PVC  
✅ Prometheus metrics collection  
✅ Grafana monitoring dashboards  
✅ Automated CI/CD pipeline  
✅ Health checks and auto-scaling  
✅ One-command deployment  

See [README.md](README.md) for complete documentation.
