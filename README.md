 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/.gitignore b/.gitignore
new file mode 100644
index 0000000000000000000000000000000000000000..17cd2fc3b7f05ee0beec0759af336a4636b73c03
--- /dev/null
+++ b/.gitignore
@@ -0,0 +1,4 @@
+.venv/
+__pycache__/
+*.pyc
+.pytest_cache/
diff --git a/projects/advanced-cloud-platform/.github/workflows/ci.yml b/projects/advanced-cloud-platform/.github/workflows/ci.yml
new file mode 100644
index 0000000000000000000000000000000000000000..b1a7af0e41a5e69669b507b14a11986ea1d9bb28
--- /dev/null
+++ b/projects/advanced-cloud-platform/.github/workflows/ci.yml
@@ -0,0 +1,22 @@
+name: CI
+
+on:
+  push:
+    branches: ["**"]
+  pull_request:
+
+jobs:
+  test:
+    runs-on: ubuntu-latest
+    defaults:
+      run:
+        working-directory: projects/advanced-cloud-platform
+    steps:
+      - uses: actions/checkout@v4
+      - uses: actions/setup-python@v5
+        with:
+          python-version: "3.12"
+      - name: Install dependencies
+        run: pip install -r app/requirements.txt
+      - name: Run tests
+        run: pytest -q
diff --git a/projects/advanced-cloud-platform/README.md b/projects/advanced-cloud-platform/README.md
new file mode 100644
index 0000000000000000000000000000000000000000..d3c8cb9c7422e4c52b71a41cfbade133a78433b7
--- /dev/null
+++ b/projects/advanced-cloud-platform/README.md
@@ -0,0 +1,71 @@
+# Advanced Cloud Project
+
+This repository contains an **advanced cloud-ready reference project** designed for production-style deployment workflows.
+
+## What is included
+
+- **Containerized API service** (`FastAPI`) with health and metrics endpoints.
+- **Infrastructure as Code** with Terraform modules for:
+  - VPC/network setup
+  - Compute cluster placeholder
+  - Managed database placeholder
+- **Kubernetes manifests** for deployment, service, autoscaling, and ingress.
+- **CI pipeline** for linting and tests on every push/PR.
+- **Utility scripts** to bootstrap local development.
+
+## Project structure
+
+```text
+projects/advanced-cloud-platform/
+├── app/                      # Python API service
+├── infra/terraform/          # Terraform root + reusable modules
+├── k8s/                      # Kubernetes deployment files
+├── scripts/                  # Dev helper scripts
+├── tests/                    # Unit tests
+└── .github/workflows/        # CI automation
+```
+
+## Quick start
+
+### 1) Local API run
+
+```bash
+cd projects/advanced-cloud-platform
+python3 -m venv .venv
+source .venv/bin/activate
+pip install -r app/requirements.txt
+uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
+```
+
+### 2) Docker build
+
+```bash
+docker build -t advanced-cloud-api:latest app
+```
+
+### 3) Terraform validate
+
+```bash
+cd infra/terraform
+terraform init
+terraform validate
+```
+
+### 4) Kubernetes deploy (example)
+
+```bash
+kubectl apply -f k8s/deployment.yaml
+kubectl apply -f k8s/service.yaml
+kubectl apply -f k8s/hpa.yaml
+kubectl apply -f k8s/ingress.yaml
+```
+
+## Environment variables
+
+- `APP_NAME` (default: `advanced-cloud-api`)
+- `APP_ENV` (default: `dev`)
+- `APP_VERSION` (default: `1.0.0`)
+
+## Notes
+
+This is intentionally cloud-provider-agnostic and can be adapted to AWS/GCP/Azure by wiring provider-specific resources in the Terraform modules.
diff --git a/projects/advanced-cloud-platform/app/Dockerfile b/projects/advanced-cloud-platform/app/Dockerfile
new file mode 100644
index 0000000000000000000000000000000000000000..cb3f9ee712d1e6fe0a04624f7ea9d36a76ac244b
--- /dev/null
+++ b/projects/advanced-cloud-platform/app/Dockerfile
@@ -0,0 +1,12 @@
+FROM python:3.12-slim
+
+WORKDIR /service
+
+COPY requirements.txt /service/requirements.txt
+RUN pip install --no-cache-dir -r /service/requirements.txt
+
+COPY main.py /service/main.py
+
+EXPOSE 8080
+
+CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
diff --git a/projects/advanced-cloud-platform/app/main.py b/projects/advanced-cloud-platform/app/main.py
new file mode 100644
index 0000000000000000000000000000000000000000..8ef471aa6b032a73048814540169e73f108fe1b2
--- /dev/null
+++ b/projects/advanced-cloud-platform/app/main.py
@@ -0,0 +1,26 @@
+from os import getenv
+from typing import Dict
+
+from fastapi import FastAPI
+
+app = FastAPI(title="Advanced Cloud API", version=getenv("APP_VERSION", "1.0.0"))
+
+
+@app.get("/health")
+def health() -> Dict[str, str]:
+    return {"status": "ok", "environment": getenv("APP_ENV", "dev")}
+
+
+@app.get("/metadata")
+def metadata() -> Dict[str, str]:
+    return {
+        "name": getenv("APP_NAME", "advanced-cloud-api"),
+        "version": getenv("APP_VERSION", "1.0.0"),
+        "environment": getenv("APP_ENV", "dev"),
+    }
+
+
+@app.get("/metrics")
+def metrics() -> Dict[str, int]:
+    # Placeholder metric response for demonstration.
+    return {"requests_total": 1, "healthy_nodes": 3}
diff --git a/projects/advanced-cloud-platform/app/requirements.txt b/projects/advanced-cloud-platform/app/requirements.txt
new file mode 100644
index 0000000000000000000000000000000000000000..cfbe44ebb096efccc86fc965d4b2089564203e4f
--- /dev/null
+++ b/projects/advanced-cloud-platform/app/requirements.txt
@@ -0,0 +1,4 @@
+fastapi==0.111.0
+uvicorn==0.30.1
+pytest==8.2.2
+httpx==0.27.0
diff --git a/projects/advanced-cloud-platform/infra/terraform/main.tf b/projects/advanced-cloud-platform/infra/terraform/main.tf
new file mode 100644
index 0000000000000000000000000000000000000000..aa9c7a3725ee59e372a1bf759c3130dbd9fb570c
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/main.tf
@@ -0,0 +1,40 @@
+terraform {
+  required_version = ">= 1.5.0"
+
+  required_providers {
+    null = {
+      source  = "hashicorp/null"
+      version = "~> 3.2"
+    }
+  }
+}
+
+module "network" {
+  source               = "./modules/network"
+  project_name         = var.project_name
+  environment          = var.environment
+  cidr_block           = var.cidr_block
+  private_subnet_count = var.private_subnet_count
+  public_subnet_count  = var.public_subnet_count
+}
+
+module "compute" {
+  source              = "./modules/compute"
+  project_name        = var.project_name
+  environment         = var.environment
+  desired_node_count  = var.desired_node_count
+  node_instance_class = var.node_instance_class
+  network_id          = module.network.network_id
+}
+
+module "database" {
+  source          = "./modules/database"
+  project_name    = var.project_name
+  environment     = var.environment
+  network_id      = module.network.network_id
+  engine          = var.db_engine
+  engine_version  = var.db_engine_version
+  instance_class  = var.db_instance_class
+  storage_gb      = var.db_storage_gb
+  multi_az        = var.db_multi_az
+}
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/compute/main.tf b/projects/advanced-cloud-platform/infra/terraform/modules/compute/main.tf
new file mode 100644
index 0000000000000000000000000000000000000000..98d1f15de38c160699ef9f0e6bf9a083949fd74a
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/compute/main.tf
@@ -0,0 +1,9 @@
+resource "null_resource" "compute" {
+  triggers = {
+    project_name        = var.project_name
+    environment         = var.environment
+    desired_node_count  = var.desired_node_count
+    node_instance_class = var.node_instance_class
+    network_id          = var.network_id
+  }
+}
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/compute/outputs.tf b/projects/advanced-cloud-platform/infra/terraform/modules/compute/outputs.tf
new file mode 100644
index 0000000000000000000000000000000000000000..772c8aba362b239799b3953790811a631439e4bb
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/compute/outputs.tf
@@ -0,0 +1,3 @@
+output "cluster_id" {
+  value = "${var.project_name}-${var.environment}-cluster"
+}
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/compute/variables.tf b/projects/advanced-cloud-platform/infra/terraform/modules/compute/variables.tf
new file mode 100644
index 0000000000000000000000000000000000000000..007efc76ac37790ac568a32fb5a4a65d798fb789
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/compute/variables.tf
@@ -0,0 +1,5 @@
+variable "project_name" { type = string }
+variable "environment" { type = string }
+variable "desired_node_count" { type = number }
+variable "node_instance_class" { type = string }
+variable "network_id" { type = string }
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/database/main.tf b/projects/advanced-cloud-platform/infra/terraform/modules/database/main.tf
new file mode 100644
index 0000000000000000000000000000000000000000..f8b4094f0c24380bb79824735d2c3c648b5025e8
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/database/main.tf
@@ -0,0 +1,12 @@
+resource "null_resource" "database" {
+  triggers = {
+    project_name   = var.project_name
+    environment    = var.environment
+    network_id     = var.network_id
+    engine         = var.engine
+    engine_version = var.engine_version
+    instance_class = var.instance_class
+    storage_gb     = var.storage_gb
+    multi_az       = var.multi_az
+  }
+}
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/database/outputs.tf b/projects/advanced-cloud-platform/infra/terraform/modules/database/outputs.tf
new file mode 100644
index 0000000000000000000000000000000000000000..7b92e2e56762c00d2ad8b9ee41fcbc2f8e2c5ada
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/database/outputs.tf
@@ -0,0 +1,3 @@
+output "database_endpoint" {
+  value = "${var.project_name}-${var.environment}.${var.engine}.internal"
+}
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/database/variables.tf b/projects/advanced-cloud-platform/infra/terraform/modules/database/variables.tf
new file mode 100644
index 0000000000000000000000000000000000000000..72ed9bcab0149cd556e83f129faa6de1892cf2e4
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/database/variables.tf
@@ -0,0 +1,8 @@
+variable "project_name" { type = string }
+variable "environment" { type = string }
+variable "network_id" { type = string }
+variable "engine" { type = string }
+variable "engine_version" { type = string }
+variable "instance_class" { type = string }
+variable "storage_gb" { type = number }
+variable "multi_az" { type = bool }
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/network/main.tf b/projects/advanced-cloud-platform/infra/terraform/modules/network/main.tf
new file mode 100644
index 0000000000000000000000000000000000000000..b6b0d17c5157613ac8ee5e80f9d6581164cd0fbd
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/network/main.tf
@@ -0,0 +1,9 @@
+resource "null_resource" "network" {
+  triggers = {
+    project_name         = var.project_name
+    environment          = var.environment
+    cidr_block           = var.cidr_block
+    private_subnet_count = var.private_subnet_count
+    public_subnet_count  = var.public_subnet_count
+  }
+}
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/network/outputs.tf b/projects/advanced-cloud-platform/infra/terraform/modules/network/outputs.tf
new file mode 100644
index 0000000000000000000000000000000000000000..7f6232d07fdaf0b83e5b9026377c27250b0e4c50
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/network/outputs.tf
@@ -0,0 +1,3 @@
+output "network_id" {
+  value = "${var.project_name}-${var.environment}-vpc"
+}
diff --git a/projects/advanced-cloud-platform/infra/terraform/modules/network/variables.tf b/projects/advanced-cloud-platform/infra/terraform/modules/network/variables.tf
new file mode 100644
index 0000000000000000000000000000000000000000..4a89745f90ab43ad22900bcb027e8e55d8ccd9b3
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/modules/network/variables.tf
@@ -0,0 +1,5 @@
+variable "project_name" { type = string }
+variable "environment" { type = string }
+variable "cidr_block" { type = string }
+variable "private_subnet_count" { type = number }
+variable "public_subnet_count" { type = number }
diff --git a/projects/advanced-cloud-platform/infra/terraform/outputs.tf b/projects/advanced-cloud-platform/infra/terraform/outputs.tf
new file mode 100644
index 0000000000000000000000000000000000000000..9e150e80b1ea38fc28d8db602b69cbb2d1b1d5f7
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/outputs.tf
@@ -0,0 +1,11 @@
+output "network_id" {
+  value = module.network.network_id
+}
+
+output "cluster_id" {
+  value = module.compute.cluster_id
+}
+
+output "database_endpoint" {
+  value = module.database.database_endpoint
+}
diff --git a/projects/advanced-cloud-platform/infra/terraform/variables.tf b/projects/advanced-cloud-platform/infra/terraform/variables.tf
new file mode 100644
index 0000000000000000000000000000000000000000..25c8c1c725bb34171a0f64f60e3b407ab54e2a66
--- /dev/null
+++ b/projects/advanced-cloud-platform/infra/terraform/variables.tf
@@ -0,0 +1,62 @@
+variable "project_name" {
+  type        = string
+  description = "Project identifier"
+  default     = "advanced-cloud-platform"
+}
+
+variable "environment" {
+  type        = string
+  description = "Environment name"
+  default     = "dev"
+}
+
+variable "cidr_block" {
+  type        = string
+  description = "Network CIDR block"
+  default     = "10.20.0.0/16"
+}
+
+variable "private_subnet_count" {
+  type        = number
+  default     = 2
+}
+
+variable "public_subnet_count" {
+  type        = number
+  default     = 2
+}
+
+variable "desired_node_count" {
+  type        = number
+  default     = 3
+}
+
+variable "node_instance_class" {
+  type        = string
+  default     = "general-purpose.medium"
+}
+
+variable "db_engine" {
+  type        = string
+  default     = "postgres"
+}
+
+variable "db_engine_version" {
+  type        = string
+  default     = "15"
+}
+
+variable "db_instance_class" {
+  type        = string
+  default     = "db.standard.medium"
+}
+
+variable "db_storage_gb" {
+  type        = number
+  default     = 100
+}
+
+variable "db_multi_az" {
+  type        = bool
+  default     = true
+}
diff --git a/projects/advanced-cloud-platform/k8s/deployment.yaml b/projects/advanced-cloud-platform/k8s/deployment.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..a0380c8dbf3599ceb82bd8c5e08d8a4116535401
--- /dev/null
+++ b/projects/advanced-cloud-platform/k8s/deployment.yaml
@@ -0,0 +1,44 @@
+apiVersion: apps/v1
+kind: Deployment
+metadata:
+  name: advanced-cloud-api
+  labels:
+    app: advanced-cloud-api
+spec:
+  replicas: 3
+  selector:
+    matchLabels:
+      app: advanced-cloud-api
+  template:
+    metadata:
+      labels:
+        app: advanced-cloud-api
+    spec:
+      containers:
+        - name: api
+          image: advanced-cloud-api:latest
+          imagePullPolicy: IfNotPresent
+          ports:
+            - containerPort: 8080
+          env:
+            - name: APP_ENV
+              value: prod
+          readinessProbe:
+            httpGet:
+              path: /health
+              port: 8080
+            initialDelaySeconds: 5
+            periodSeconds: 10
+          livenessProbe:
+            httpGet:
+              path: /health
+              port: 8080
+            initialDelaySeconds: 10
+            periodSeconds: 15
+          resources:
+            requests:
+              cpu: 100m
+              memory: 128Mi
+            limits:
+              cpu: 500m
+              memory: 512Mi
diff --git a/projects/advanced-cloud-platform/k8s/hpa.yaml b/projects/advanced-cloud-platform/k8s/hpa.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..41034cacd7369dd5745b2bbe3208c5886afa0585
--- /dev/null
+++ b/projects/advanced-cloud-platform/k8s/hpa.yaml
@@ -0,0 +1,18 @@
+apiVersion: autoscaling/v2
+kind: HorizontalPodAutoscaler
+metadata:
+  name: advanced-cloud-api
+spec:
+  scaleTargetRef:
+    apiVersion: apps/v1
+    kind: Deployment
+    name: advanced-cloud-api
+  minReplicas: 3
+  maxReplicas: 10
+  metrics:
+    - type: Resource
+      resource:
+        name: cpu
+        target:
+          type: Utilization
+          averageUtilization: 70
diff --git a/projects/advanced-cloud-platform/k8s/ingress.yaml b/projects/advanced-cloud-platform/k8s/ingress.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..1244a81d666b1fa4a1c51fecbb5c2ab3b8462faf
--- /dev/null
+++ b/projects/advanced-cloud-platform/k8s/ingress.yaml
@@ -0,0 +1,18 @@
+apiVersion: networking.k8s.io/v1
+kind: Ingress
+metadata:
+  name: advanced-cloud-api
+  annotations:
+    kubernetes.io/ingress.class: nginx
+spec:
+  rules:
+    - host: api.example.internal
+      http:
+        paths:
+          - path: /
+            pathType: Prefix
+            backend:
+              service:
+                name: advanced-cloud-api
+                port:
+                  number: 80
diff --git a/projects/advanced-cloud-platform/k8s/service.yaml b/projects/advanced-cloud-platform/k8s/service.yaml
new file mode 100644
index 0000000000000000000000000000000000000000..e7865fdddd32a6922ef8ada1ad53e6507d39877b
--- /dev/null
+++ b/projects/advanced-cloud-platform/k8s/service.yaml
@@ -0,0 +1,11 @@
+apiVersion: v1
+kind: Service
+metadata:
+  name: advanced-cloud-api
+spec:
+  type: ClusterIP
+  selector:
+    app: advanced-cloud-api
+  ports:
+    - port: 80
+      targetPort: 8080
diff --git a/projects/advanced-cloud-platform/scripts/bootstrap.sh b/projects/advanced-cloud-platform/scripts/bootstrap.sh
new file mode 100755
index 0000000000000000000000000000000000000000..e79f3d7c3f3523f385fd6d96bd7002b60e2c9ddd
--- /dev/null
+++ b/projects/advanced-cloud-platform/scripts/bootstrap.sh
@@ -0,0 +1,11 @@
+#!/usr/bin/env bash
+set -euo pipefail
+
+ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
+
+python3 -m venv "$ROOT_DIR/.venv"
+source "$ROOT_DIR/.venv/bin/activate"
+pip install --upgrade pip
+pip install -r "$ROOT_DIR/app/requirements.txt"
+
+echo "Bootstrap complete. Activate with: source $ROOT_DIR/.venv/bin/activate"
diff --git a/projects/advanced-cloud-platform/tests/test_main.py b/projects/advanced-cloud-platform/tests/test_main.py
new file mode 100644
index 0000000000000000000000000000000000000000..de9c8e93b348180d482e9772cdecb4cf028667c0
--- /dev/null
+++ b/projects/advanced-cloud-platform/tests/test_main.py
@@ -0,0 +1,28 @@
+from fastapi.testclient import TestClient
+
+from app.main import app
+
+
+client = TestClient(app)
+
+
+def test_health_endpoint() -> None:
+    response = client.get("/health")
+    assert response.status_code == 200
+    data = response.json()
+    assert data["status"] == "ok"
+
+
+def test_metadata_endpoint() -> None:
+    response = client.get("/metadata")
+    assert response.status_code == 200
+    data = response.json()
+    assert "name" in data
+    assert "version" in data
+
+
+def test_metrics_endpoint() -> None:
+    response = client.get("/metrics")
+    assert response.status_code == 200
+    data = response.json()
+    assert data["healthy_nodes"] >= 1
 
EOF
)
