@echo off
echo 🧹 Cleaning up Kubernetes resources...

kubectl delete -f k8s/frontend-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/backend-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/redis-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/postgres-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/grafana-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/prometheus-deployment.yaml --ignore-not-found=true
kubectl delete namespace monitoring --ignore-not-found=true

echo ✅ Cleanup complete!
pause
