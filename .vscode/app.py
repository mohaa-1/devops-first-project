from flask import Flask, jsonify
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello DevOps!"

@app.route("/health")
def health():
    return jsonify({"status": "ok"}), 200

@app.route("/api/info")
def info():
    return jsonify({
        "app": "devops-first-project",
        "version": "1.0.0",
        "status": "running"
    }), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
