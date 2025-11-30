# Deployment Checklist ✅

Use this checklist to ensure successful deployment of the microservices application.

## Pre-Deployment Checklist

### Environment Setup
- [ ] Docker installed and running
- [ ] Kubernetes cluster available (minikube/Docker Desktop/cloud)
- [ ] kubectl installed and configured
- [ ] kubectl can connect to cluster: `kubectl cluster-info`
- [ ] Sufficient resources: 4GB RAM, 2 CPU cores minimum

### Optional Tools
- [ ] make installed (for Makefile commands)
- [ ] Node.js 18+ (for local frontend development)
- [ ] Python 3.10+ (for local backend development)

## Deployment Steps

### 1. Build Docker Images
```bash
# Option A: Using Make
make build

# Option B: Manual
docker build -t backend:latest ./backend
docker build -t frontend:latest ./frontend
```

- [ ] Backend image built successfully
- [ ] Frontend image built successfully
- [ ] No build errors in output

### 2. Load Images (if using minikube)
```bash
minikube image load backend:latest
minikube image load frontend:latest
```

- [ ] Images loaded to minikube
- [ ] Verify: `minikube image ls | grep backend`
- [ ] Verify: `minikube image ls | grep frontend`

### 3. Deploy Database Layer
```bash
kubectl apply -f k8s/postgres-deployment.yaml
```

Wait for PostgreSQL to be ready:
```bash
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s
```

- [ ] PostgreSQL pod running
- [ ] PVC created and bound
- [ ] Service accessible: `kubectl get svc postgres-service`

### 4. Deploy Cache Layer
```bash
kubectl apply -f k8s/redis-deployment.yaml
```

Wait for Redis to be ready:
```bash
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s
```

- [ ] Redis pod running
- [ ] Service accessible: `kubectl get svc redis-service`
- [ ] Test connection: `kubectl exec -it deployment/redis -- redis-cli ping`

### 5. Deploy Backend API
```bash
kubectl apply -f k8s/backend-deployment.yaml
```

Wait for backend to be ready:
```bash
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s
```

- [ ] Backend pods running (2 replicas)
- [ ] Service accessible: `kubectl get svc backend-service`
- [ ] Health check passing: `kubectl exec -it deployment/backend -- curl localhost:5000/health`

### 6. Deploy Frontend
```bash
kubectl apply -f k8s/frontend-deployment.yaml
```

Wait for frontend to be ready:
```bash
kubectl wait --for=condition=ready pod -l app=frontend --timeout=120s
```

- [ ] Frontend pods running (2 replicas)
- [ ] NodePort service created

### 7. Deploy Monitoring (Optional)
```bash
kubectl apply -f k8s/prometheus-deployment.yaml
kubectl apply -f k8s/grafana-deployment.yaml
```

- [ ] Prometheus pod running in monitoring namespace
- [ ] Grafana pod running in monitoring namespace
- [ ] Services accessible

## Verification Steps

### Check All Pods
```bash
kubectl get pods --all-namespaces
```

Expected output:
```
NAMESPACE     NAME                          READY   STATUS    RESTARTS
default       backend-xxx                   1/1     Running   0
default       backend-yyy                   1/1     Running   0
default       frontend-xxx                  1/1     Running   0
default       frontend-yyy                  1/1     Running   0
default       postgres-zzz                  1/1     Running   0
default       redis-aaa                     1/1     Running   0
monitoring    prometheus-bbb                1/1     Running   0
monitoring    grafana-ccc                   1/1     Running   0
```

- [ ] All pods in Running state
- [ ] All pods show READY 1/1
- [ ] No CrashLoopBackOff errors

### Check Services
```bash
kubectl get services --all-namespaces
```

- [ ] frontend-service (NodePort 30080)
- [ ] backend-service (ClusterIP 5000)
- [ ] postgres-service (ClusterIP 5432)
- [ ] redis-service (ClusterIP 6379)
- [ ] prometheus-service (NodePort 30090)
- [ ] grafana-service (NodePort 30300)

### Test Application Access

#### Frontend
```bash
# If using minikube
minikube service frontend-service --url

# If using Docker Desktop/other
# Access: http://localhost:30080
```

- [ ] Frontend loads in browser
- [ ] Status cards show "connected" for API, DB, and Cache
- [ ] Can add a new task
- [ ] Can mark task as complete
- [ ] Can delete a task

#### Backend API
```bash
# Port forward for testing
kubectl port-forward service/backend-service 5000:5000

# Test endpoints
curl http://localhost:5000/
curl http://localhost:5000/health
curl http://localhost:5000/api/tasks
```

- [ ] API status endpoint responds
- [ ] Health endpoint shows healthy
- [ ] Tasks endpoint returns JSON

#### Prometheus
Access: http://localhost:30090

- [ ] Prometheus UI loads
- [ ] Navigate to Status > Targets
- [ ] Backend target shows as UP
- [ ] Can execute query: `app_request_count`

#### Grafana
Access: http://localhost:30300
Login: admin/admin123

- [ ] Grafana UI loads
- [ ] Can login successfully
- [ ] Prometheus datasource configured
- [ ] Dashboards present

### Test Database Persistence
```bash
# Add a task via UI
# Delete backend pods
kubectl delete pod -l app=backend

# Wait for new pods
kubectl wait --for=condition=ready pod -l app=backend --timeout=60s

# Refresh frontend - tasks should still be there
```

- [ ] Tasks persist after pod restart
- [ ] Database data not lost

### Test Cache Functionality
```bash
# Clear Redis cache
kubectl exec -it deployment/redis -- redis-cli FLUSHDB

# Load tasks in UI (cache miss - slower)
# Load tasks again (cache hit - faster)

# Check cache
kubectl exec -it deployment/redis -- redis-cli KEYS "*"
```

- [ ] Cache populates on first request
- [ ] Subsequent requests use cache
- [ ] Cache TTL works (expires after 60s)

### Test Monitoring
```bash
# Generate some traffic
for i in {1..100}; do curl http://localhost:5000/api/tasks; done

# Check Prometheus
# Query: rate(app_request_count[1m])
```

- [ ] Metrics appear in Prometheus
- [ ] Request count increases
- [ ] Latency metrics recorded

## Post-Deployment Verification

### Resource Usage
```bash
kubectl top pods
kubectl top nodes
```

- [ ] Pods not exceeding resource limits
- [ ] Node has sufficient resources
- [ ] No OOMKilled pods

### Logs Check
```bash
kubectl logs -l app=backend --tail=50
kubectl logs -l app=frontend --tail=50
kubectl logs deployment/postgres --tail=50
kubectl logs deployment/redis --tail=50
```

- [ ] No error messages in logs
- [ ] Application logs show normal activity
- [ ] Database initialized successfully

### Network Connectivity
```bash
# Test pod-to-pod communication
kubectl exec -it deployment/backend -- ping postgres-service
kubectl exec -it deployment/backend -- ping redis-service
```

- [ ] Backend can reach PostgreSQL
- [ ] Backend can reach Redis
- [ ] DNS resolution working

## Troubleshooting Checklist

If deployment fails, check:

### Images
- [ ] Images built successfully
- [ ] Images loaded to cluster (if minikube)
- [ ] imagePullPolicy set to Never for local images

### Resources
- [ ] Cluster has sufficient memory
- [ ] Cluster has sufficient CPU
- [ ] No resource quota exceeded

### Configuration
- [ ] ConfigMaps applied
- [ ] Secrets applied
- [ ] Environment variables set correctly

### Networking
- [ ] Services created
- [ ] Correct port mappings
- [ ] NodePort in valid range (30000-32767)

### Dependencies
- [ ] Database ready before backend
- [ ] Redis ready before backend
- [ ] Backend ready before frontend accesses it

## Cleanup Checklist

To remove everything:

```bash
# Option A: Using Make
make clean

# Option B: Using scripts
scripts\cleanup.bat  # Windows
./scripts/cleanup.sh # Linux/Mac

# Option C: Manual
kubectl delete -f k8s/ --ignore-not-found=true
kubectl delete namespace monitoring --ignore-not-found=true
```

- [ ] All deployments deleted
- [ ] All services deleted
- [ ] All configmaps deleted
- [ ] All secrets deleted
- [ ] Monitoring namespace deleted
- [ ] PVCs deleted

## Success Criteria

✅ All pods running and ready  
✅ Frontend accessible and functional  
✅ Backend API responding  
✅ Database persisting data  
✅ Redis caching working  
✅ Prometheus collecting metrics  
✅ Grafana displaying dashboards  
✅ No errors in logs  
✅ Application fully functional  

## Next Steps After Deployment

1. **Explore the Application**
   - Create tasks
   - Update tasks
   - Delete tasks
   - Monitor status

2. **Check Monitoring**
   - View Prometheus metrics
   - Explore Grafana dashboards
   - Generate traffic and observe

3. **Test Scaling**
   ```bash
   kubectl scale deployment backend --replicas=5
   kubectl scale deployment frontend --replicas=3
   ```

4. **Test Resilience**
   - Delete a pod and watch it restart
   - Check that application continues working

5. **Review Logs**
   - Understand application behavior
   - Identify any warnings or issues

## Getting Help

If you encounter issues:

1. Check the troubleshooting section in README.md
2. Review logs: `kubectl logs <pod-name>`
3. Describe resources: `kubectl describe pod <pod-name>`
4. Check events: `kubectl get events --sort-by='.lastTimestamp'`
5. Verify connectivity: Use `kubectl exec` to test connections

---

**Happy Deploying! 🚀**
