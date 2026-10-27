# Marketplace Seller Risk & Abuse Detection Platform

Production-grade cloud infrastructure, database provisioning scripts, and end-to-end DevOps automation for the **Marketplace Seller Risk & Abuse Detection Platform**.

---

## 🏗️ Architecture Overview

The platform ingests real-time signals from listing creation, account logins, orders, and reviews, evaluating them across real-time velocity rules (Redis), machine learning anomaly models (Python FastAPI/IsolationForest), and Spring Boot policy orchestration.

```
┌────────────────────────────────────────────────────────┐
│               Marketplace Signal Ingestion             │
│    (Listings, Seller Logins, Orders, Review Streams)   │
└───────────────────────────┬────────────────────────────┘
                            │ Kafka / REST
                            ▼
┌────────────────────────────────────────────────────────┐
│          Marketplace Risk Backend (Java 21)            │
│  - Signal Normalization & Ingestion                    │
│  - Velocity Rule Engine (Redis Sliding Windows)        │
│  - Composite Risk Scorer (45% Velocity + 55% ML)       │
│  - Case Queue API & Automated Routing                  │
└──────────────┬──────────────────────────┬──────────────┘
               │                          │
        HTTP /score                       │ REST
               ▼                          ▼
┌─────────────────────────────┐  ┌───────────────────────┐
│ Anomaly Scoring Model (ML)  │  │ Trust & Safety Portal │
│ - Python 3.12 + FastAPI     │  │ - React 19 + Node 22  │
│ - Isolation Forest Scorer   │  │ - Real-time Triage    │
│ - ATO & Burst Profiler      │  │ - Manual Enforcements │
└─────────────────────────────┘  └───────────────────────┘
```

---

## ☁️ Infrastructure Provisioning (Terraform)

Terraform provisions the complete AWS stack using HashiCorp AWS Provider `~> 6.70.0`:
- **VPC**: Multi-AZ with public, private, and isolated data subnets, NAT Gateway.
- **EKS**: Kubernetes 1.32 Managed Cluster with autoscaling worker node groups and HPA.
- **RDS**: Multi-AZ PostgreSQL 16.x for transactional case state and entity records.
- **ElastiCache Redis**: Multi-node Redis 7.1 cluster for sub-millisecond velocity sliding windows.
- **CI/CD Host**: Jenkins Master and Worker EC2 instances with IAM instance profiles.
- **Bastion Host**: Secure SSH gateway into private subnets.

### Provisioning Steps
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply -auto-approve
```

---

## 🗄️ Database Initialization (PostgreSQL)

Execute the initialization script against the provisioned RDS endpoint or local PostgreSQL container:

```bash
# Connect using psql
psql -h YOUR_RDS_ENDPOINT -U postgres -d postgres -f database_scripts/init.sql
```

This creates:
- Databases: `marketplace_risk` (Prod), `marketplace_risk_dev`, `marketplace_risk_staging`
- Dedicated user: `riskuser` / `riskpass123`
- Tables: `sellers`, `risk_cases`, `enforcement_actions`
- Performance indexes on `seller_id`, `status`, `risk_tier`, and `created_at`
- Realistic seed data for immediate validation

---

## 🚀 Repositories in the Suite

| Repository | Description |
| :--- | :--- |
| **[`jenkins-sharedlibraries`](https://github.com/nagaraj602/jenkins-sharedlibraries.git)** | Reusable pipeline library (`trivyScan`, `sonarAnalysis`, `dockerECRImagePush`, `kubernetesEKSHelmDeployEnv`) |
| **[`marketplace-risk-backend`](https://github.com/nagaraj602/marketplace-risk-backend.git)** | Core detection engine, Spring Boot 4.1.2 on Java 21, REST APIs, Helm charts |
| **[`marketplace-risk-anomaly-model`](https://github.com/nagaraj602/marketplace-risk-anomaly-model.git)** | Python 3.12 ML service, FastAPI, IsolationForest, Helm charts |
| **[`marketplace-risk-frontend`](https://github.com/nagaraj602/marketplace-risk-frontend.git)** | React 19 Trust & Safety analyst portal with live simulator, Helm charts |
| **[`marketplace-risk-platform`](https://github.com/nagaraj602/marketplace-risk-platform.git)** | Terraform IaC modules and database schemas |
