from flask import Flask, jsonify, request
from flask_cors import CORS
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import psycopg2
import redis
import os
import json
from datetime import datetime
from functools import wraps
import time

app = Flask(__name__)
CORS(app)

# Prometheus metrics
REQUEST_COUNT = Counter('app_request_count', 'Total request count', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('app_request_latency_seconds', 'Request latency', ['method', 'endpoint'])

# Redis connection
def get_redis_connection():
    return redis.Redis(
        host=os.getenv('REDIS_HOST', 'redis-service'),
        port=int(os.getenv('REDIS_PORT', 6379)),
        db=0,
        decode_responses=True
    )

# Database connection
def get_db_connection():
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST', 'postgres-service'),
        database=os.getenv('DB_NAME', 'microservices_db'),
        user=os.getenv('DB_USER', 'postgres'),
        password=os.getenv('DB_PASSWORD', 'password')
    )
    return conn

@app.route('/')
def home():
    return jsonify({"message": "Backend API is running", "status": "ok"})

@app.route('/health')
def health():
    try:
        # Check database
        conn = get_db_connection()
        conn.close()
        db_status = "connected"
    except Exception as e:
        db_status = "error"
    
    try:
        # Check Redis
        r = get_redis_connection()
        r.ping()
        cache_status = "connected"
    except Exception as e:
        cache_status = "error"
    
    return jsonify({
        "status": "healthy" if db_status == "connected" else "unhealthy",
        "database": db_status,
        "cache": cache_status
    }), 200 if db_status == "connected" else 500

@app.route('/api/tasks', methods=['GET'])
def get_tasks():
    try:
        r = get_redis_connection()
        
        # Try to get from cache
        cached_tasks = r.get('tasks:all')
        if cached_tasks:
            REQUEST_COUNT.labels(method='GET', endpoint='/api/tasks', status='200_cached').inc()
            return jsonify(json.loads(cached_tasks))
        
        # Get from database
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('SELECT id, title, completed, created_at FROM tasks ORDER BY created_at DESC;')
        tasks = cur.fetchall()
        cur.close()
        conn.close()
        
        tasks_list = [{
            'id': task[0],
            'title': task[1],
            'completed': task[2],
            'created_at': task[3].isoformat() if task[3] else None
        } for task in tasks]
        
        # Cache for 60 seconds
        r.setex('tasks:all', 60, json.dumps(tasks_list))
        
        REQUEST_COUNT.labels(method='GET', endpoint='/api/tasks', status='200_db').inc()
        return jsonify(tasks_list)
    except Exception as e:
        REQUEST_COUNT.labels(method='GET', endpoint='/api/tasks', status='500').inc()
        return jsonify({"error": str(e)}), 500

@app.route('/api/tasks', methods=['POST'])
def create_task():
    try:
        data = request.get_json()
        title = data.get('title')
        
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('INSERT INTO tasks (title, completed) VALUES (%s, %s) RETURNING id, created_at;',
                   (title, False))
        result = cur.fetchone()
        task_id = result[0]
        created_at = result[1]
        conn.commit()
        cur.close()
        conn.close()
        
        # Invalidate cache
        r = get_redis_connection()
        r.delete('tasks:all')
        
        REQUEST_COUNT.labels(method='POST', endpoint='/api/tasks', status='201').inc()
        return jsonify({
            "id": task_id,
            "title": title,
            "completed": False,
            "created_at": created_at.isoformat() if created_at else None
        }), 201
    except Exception as e:
        REQUEST_COUNT.labels(method='POST', endpoint='/api/tasks', status='500').inc()
        return jsonify({"error": str(e)}), 500

@app.route('/api/tasks/<int:task_id>', methods=['PUT'])
def update_task(task_id):
    try:
        data = request.get_json()
        completed = data.get('completed')
        
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('UPDATE tasks SET completed = %s WHERE id = %s;',
                   (completed, task_id))
        conn.commit()
        cur.close()
        conn.close()
        
        # Invalidate cache
        r = get_redis_connection()
        r.delete('tasks:all')
        
        REQUEST_COUNT.labels(method='PUT', endpoint='/api/tasks', status='200').inc()
        return jsonify({"id": task_id, "completed": completed})
    except Exception as e:
        REQUEST_COUNT.labels(method='PUT', endpoint='/api/tasks', status='500').inc()
        return jsonify({"error": str(e)}), 500

@app.route('/api/tasks/<int:task_id>', methods=['DELETE'])
def delete_task(task_id):
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('DELETE FROM tasks WHERE id = %s;', (task_id,))
        conn.commit()
        cur.close()
        conn.close()
        
        # Invalidate cache
        r = get_redis_connection()
        r.delete('tasks:all')
        
        REQUEST_COUNT.labels(method='DELETE', endpoint='/api/tasks', status='200').inc()
        return jsonify({"message": "Task deleted"}), 200
    except Exception as e:
        REQUEST_COUNT.labels(method='DELETE', endpoint='/api/tasks', status='500').inc()
        return jsonify({"error": str(e)}), 500

@app.route('/metrics')
def metrics():
    # Prometheus metrics endpoint
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/api/cache/clear', methods=['POST'])
def clear_cache():
    try:
        r = get_redis_connection()
        r.delete('tasks:all')
        return jsonify({"message": "Cache cleared"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Initialize database table
    try:
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute('''
            CREATE TABLE IF NOT EXISTS tasks (
                id SERIAL PRIMARY KEY,
                title VARCHAR(255) NOT NULL,
                completed BOOLEAN DEFAULT FALSE,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        ''')
        conn.commit()
        cur.close()
        conn.close()
        print("Database initialized successfully")
    except Exception as e:
        print(f"Database initialization error: {e}")
    
    app.run(host='0.0.0.0', port=5000, debug=False)
