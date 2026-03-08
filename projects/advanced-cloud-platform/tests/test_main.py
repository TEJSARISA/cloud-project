from fastapi.testclient import TestClient

from app.main import app


client = TestClient(app)


def test_health_endpoint() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"


def test_metadata_endpoint() -> None:
    response = client.get("/metadata")
    assert response.status_code == 200
    data = response.json()
    assert "name" in data
    assert "version" in data


def test_metrics_endpoint() -> None:
    response = client.get("/metrics")
    assert response.status_code == 200
    data = response.json()
    assert data["healthy_nodes"] >= 1
