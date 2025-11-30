@echo off
echo 🚀 Starting deployment...

echo 📦 Building Docker images...
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend

echo 🗄️  Deploying database and cache...
kubectl apply -f k8s/postgres-deployment.yaml
kubectl apply -f k8s/redis-deployment.yaml

echo ⏳ Waiting for database and cache...
timeout /t 30 /nobreak

echo 🌐 Deploying application...
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/frontend-deployment.yaml

echo ⏳ Waiting for application...
timeout /t 30 /nobreak

echo 📊 Deploying monitoring...
kubectl apply -f k8s/prometheus-deployment.yaml
kubectl apply -f k8s/grafana-deployment.yaml

echo ✅ Deployment complete!
echo.
echo 🌐 Access URLs:
echo   Frontend: http://localhost:30080
echo   Prometheus: http://localhost:30090
echo   Grafana: http://localhost:30300 (admin/admin123)
echo.

kubectl get pods
pause
