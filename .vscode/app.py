
from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "Hello DevOps!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)


@app.route("/health")
def health():
    return {"status": "ok"}, 200


@app.route("/api/info")
def info():
    return {
        "app": "devops-first-project",
        "version": "1.0.0"
    }
