from os import getenv
from typing import Dict

from fastapi import FastAPI

app = FastAPI(title="Advanced Cloud API", version=getenv("APP_VERSION", "1.0.0"))


@app.get("/health")
def health() -> Dict[str, str]:
    return {"status": "ok", "environment": getenv("APP_ENV", "dev")}


@app.get("/metadata")
def metadata() -> Dict[str, str]:
    return {
        "name": getenv("APP_NAME", "advanced-cloud-api"),
        "version": getenv("APP_VERSION", "1.0.0"),
        "environment": getenv("APP_ENV", "dev"),
    }


@app.get("/metrics")
def metrics() -> Dict[str, int]:
    # Placeholder metric response for demonstration.
    return {"requests_total": 1, "healthy_nodes": 3}
