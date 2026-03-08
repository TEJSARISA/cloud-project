# Advanced Cloud Project

This repository contains an **advanced cloud-ready reference project** designed for production-style deployment workflows.

## What is included

- **Containerized API service** (`FastAPI`) with health and metrics endpoints.
- **Infrastructure as Code** with Terraform modules for:
  - VPC/network setup
  - Compute cluster placeholder
  - Managed database placeholder
- **Kubernetes manifests** for deployment, service, autoscaling, and ingress.
- **CI pipeline** for linting and tests on every push/PR.
- **Utility scripts** to bootstrap local development.

## Project structure

```text
projects/advanced-cloud-platform/
├── app/                      # Python API service
├── infra/terraform/          # Terraform root + reusable modules
├── k8s/                      # Kubernetes deployment files
├── scripts/                  # Dev helper scripts
├── tests/                    # Unit tests
└── .github/workflows/        # CI automation
```

## Quick start

### 1) Local API run

```bash
cd projects/advanced-cloud-platform
python3 -m venv .venv
source .venv/bin/activate
pip install -r app/requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

### 2) Docker build

```bash
docker build -t advanced-cloud-api:latest app
```

### 3) Terraform validate

```bash
cd infra/terraform
terraform init
terraform validate
```

### 4) Kubernetes deploy (example)

```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml
kubectl apply -f k8s/ingress.yaml
```

## Environment variables

- `APP_NAME` (default: `advanced-cloud-api`)
- `APP_ENV` (default: `dev`)
- `APP_VERSION` (default: `1.0.0`)

## Notes

This is intentionally cloud-provider-agnostic and can be adapted to AWS/GCP/Azure by wiring provider-specific resources in the Terraform modules.
