# test_app.py
from app import app


def test_home():
    client = app.test_client()
    res = client.get("/")
    assert res.status_code == 200
    assert b"Hello DevOps!" in res.data


def test_health():
    client = app.test_client()
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json == {"status": "ok"}


def test_info():
    client = app.test_client()
    res = client.get("/api/info")
    assert res.status_code == 200
    assert res.json.get("app") == "devops-first-project"
