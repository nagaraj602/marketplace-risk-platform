# Marketplace Seller Risk & Abuse Detection Platform

An enterprise-grade, real-time risk intelligence and automated abuse mitigation platform built for large-scale e-commerce marketplaces. The platform protects buyer trust by detecting fraudulent patterns (listing bursts, account takeovers, review manipulation, and device collisions) in near real-time, automatically enforcing takedowns on high-confidence cases, and prioritizing lower-confidence cases for Trust & Safety analysts.

---

## 🔗 Platform Repositories

The complete microservices suite, infrastructure, and CI/CD pipelines are maintained across five dedicated repositories:

| Repository | GitHub Link | Purpose & Tech Stack |
| :--- | :--- | :--- |
| **Platform & Infrastructure** | [nagaraj602/marketplace-risk-platform](https://github.com/nagaraj602/marketplace-risk-platform.git) | Terraform AWS IaC (VPC, EKS 1.37, RDS PostgreSQL 17, Redis 7.4, Jenkins), DB init scripts, Docker Compose |
| **Core Risk Backend** | [nagaraj602/marketplace-risk-backend](https://github.com/nagaraj602/marketplace-risk-backend.git) | Java 21, Spring Boot 4.1.2, JPA, Velocity Rule Engine, Risk Aggregation, Enforcement Orchestration |
| **ML Anomaly Model** | [nagaraj602/marketplace-risk-anomaly-model](https://github.com/nagaraj602/marketplace-risk-anomaly-model.git) | Python 3.15.2, FastAPI 0.162, scikit-learn 1.9.1 Isolation Forest, behavioral anomaly inference |
| **Trust & Safety Portal** | [nagaraj602/marketplace-risk-frontend](https://github.com/nagaraj602/marketplace-risk-frontend.git) | React 19, Vite 8, Node 24, Express 5, Lucide-React, live review queue & signal injection simulator |
| **Jenkins Shared Libraries** | [nagaraj602/jenkins-sharedlibraries](https://github.com/nagaraj602/jenkins-sharedlibraries.git) | Reusable Groovy pipeline vars (`trivyScan`, `sonarAnalysis`, `dockerECRImagePush`, `kubernetesEKSHelmDeployEnv`) |

---

## 🏗️ Architecture & Data Flow

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
│ - Python 3.15.2 + FastAPI   │  │ - React 19 + Node 24  │
│ - Isolation Forest Scorer   │  │ - Real-time Triage    │
│ - ATO & Burst Profiler      │  │ - Manual Enforcements │
└─────────────────────────────┘  └───────────────────────┘
```

1. **Signals Ingestion**: Ingests seller listing updates, IP/device logins, orders, and reviews.
2. **Velocity Evaluation**: Evaluates sliding window frequencies in Redis (e.g., >50 listings/hour, multi-device collisions).
3. **ML Anomaly Inference**: Python FastAPI service runs unsupervised Isolation Forest and z-score models.
4. **Risk Aggregation**: Combines velocity score (45%) and ML anomaly score (55%) into a composite score (0-100).
5. **Dynamic Routing**:
   - **Score >= 85 (Critical)**: Triggers immediate automated enforcement (`SUSPEND_SELLER`, `HOLD_PAYOUT`).
   - **50 <= Score < 85 (High/Elevated)**: Pushes case to the Trust & Safety Analyst Queue with SLA countdown.
   - **Score < 50 (Low)**: Automatically dismissed to prevent analyst alert fatigue.

---

## ⚙️ Prerequisites & System Requirements

Ensure the following tools are installed on your workstation:
- **Docker & Docker Compose** (Docker 24+ / Compose v2)
- **Java Development Kit (JDK 21)** (OpenJDK or Eclipse Temurin)
- **Apache Maven 3.9+**
- **Python 3.15.2+**
- **Node.js 24 LTS+** & **npm**
- **AWS CLI v2** & **Terraform 1.5+** (for AWS deployments)
- **kubectl** & **Helm 3.x**

---

## 🛠️ How to Setup This App

### Method 1: Instant Local Setup via Docker Compose (Recommended)

Run all microservices, databases, and caches with a single command:

1. Clone all 5 repositories into a common parent directory:
```bash
git clone https://github.com/nagaraj602/marketplace-risk-platform.git
git clone https://github.com/nagaraj602/marketplace-risk-backend.git
git clone https://github.com/nagaraj602/marketplace-risk-frontend.git
git clone https://github.com/nagaraj602/marketplace-risk-anomaly-model.git
git clone https://github.com/nagaraj602/jenkins-sharedlibraries.git
```

2. Start the entire platform:
```bash
cd marketplace-risk-platform
docker compose up --build -d
```

3. Check container health status:
```bash
docker compose ps
```

4. Service Endpoints:
- **Trust & Safety Portal**: [http://localhost:3000](http://localhost:3000)
- **Risk Backend API**: [http://localhost:8080](http://localhost:8080)
- **Actuator Health**: [http://localhost:8080/actuator/health](http://localhost:8080/actuator/health)
- **ML Anomaly Model API & Swagger Docs**: [http://localhost:5000/docs](http://localhost:5000/docs)
- **PostgreSQL Database**: `localhost:5432` (`marketplace_risk`)
- **Redis Cache**: `localhost:6379`

---

### Method 2: Manual Standalone Development Setup

If you wish to run each microservice directly on your host:

#### Step 1: Start PostgreSQL and Redis
```bash
docker run -d --name risk-postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgrespassword postgres:16-alpine
docker run -d --name risk-redis -p 6379:6379 redis:7.4-alpine

# Initialize PostgreSQL Schema
psql -h localhost -U postgres -d postgres -f marketplace-risk-platform/database_scripts/init.sql
```

#### Step 2: Start the Python Anomaly Model Service
```bash
cd marketplace-risk-anomaly-model
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run unit tests
python3 -m unittest discover tests

# Start API server on port 5000
python3 app.py
```

#### Step 3: Start the Spring Boot Backend Service
```bash
cd marketplace-risk-backend
# Run unit & integration tests
mvn clean test

# Start service on port 8080
mvn spring-boot:run
```

#### Step 4: Start the Frontend Trust & Safety Console
```bash
cd marketplace-risk-frontend
npm install
npm run build
node server.js
# Or start interactive Vite dev server:
npm run dev
```

---

### Method 3: Cloud Deployment on AWS (Terraform + EKS + Helm)

#### 1. Provision Infrastructure via Terraform
```bash
cd marketplace-risk-platform/terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply -auto-approve
```

#### 2. Configure Local Kubernetes Context
```bash
aws eks update-kubeconfig --region ap-south-1 --name marketplace-risk-platform-eks
```

#### 3. Deploy Applications via Helm
```bash
# 1. Deploy ML Model
helm upgrade --install marketplace-risk-anomaly-model ../marketplace-risk-anomaly-model/helm/ \
  --namespace prod --create-namespace -f ../marketplace-risk-anomaly-model/helm/values/PROD.yaml

# 2. Deploy Risk Backend
helm upgrade --install marketplace-risk-backend ../marketplace-risk-backend/helm/ \
  --namespace prod --create-namespace -f ../marketplace-risk-backend/helm/values/PROD.yaml

# 3. Deploy Frontend Portal
helm upgrade --install marketplace-risk-frontend ../marketplace-risk-frontend/helm/ \
  --namespace prod --create-namespace -f ../marketplace-risk-frontend/helm/values/PROD.yaml
```

---

## 🎮 How to Use & Operate This App

### 1. Navigating the Trust & Safety Console
Open your web browser at **[http://localhost:3000](http://localhost:3000)**.
- **Top Telemetry Bar**: Live indicators for Pending Queue Depth, Automated Takedowns, False Positive Rate (target <5%), and Pipeline Latency (SLO <10 min).
- **Prioritized Case Queue**: Displays incoming high-risk seller cases ordered by severity with SLA deadlines.
- **Signal Simulator**: Interactive tool to inject simulated abuse traffic into the system.

### 2. Operating the Live Signal Simulator
Use the simulator cards at the bottom of the portal to test the detection pipeline:
- **Scenario A: Flash Sale Listing Flood**
  - Injects a burst of 95 listings/hour from 5 shared devices on a 3-day-old account.
  - **Result**: Composite score ~92/100 (`CRITICAL`). Triggers **Automated Enforcement** (`SUSPEND_SELLER` + `HOLD_PAYOUT`) without human intervention.
- **Scenario B: Account Takeover (ATO)**
  - Injects a payout account change combined with a foreign IP geolocation mismatch.
  - **Result**: Composite score ~71/100 (`HIGH`). Routes case to the **Pending Review Queue** for analyst review.
- **Scenario C: Review Manipulation Ring**
  - Injects an order surge with high negative review disputes.
  - **Result**: Composite score ~54/100 (`ELEVATED`). Enters the review queue.
- **Scenario D: Legitimate Power Seller**
  - Injects standard traffic for an aged, high-rated seller.
  - **Result**: Composite score ~18/100 (`LOW`). Routed to `DISMISSED` to prevent false positive noise.

### 3. Triage & Deep-Dive Entity Inspection
In the Case Queue table:
1. Click the **Eye icon** (`Inspect`) on any case row.
2. The **Entity Risk Profile Modal** opens, showing:
   - Composite Score Breakdown (45% Velocity Rule Engine vs. 55% ML Model).
   - Triggered Detection Signals (e.g., `RULE_RAPID_PAYOUT_MODIFICATION`, `SUSPICIOUS_MULTI_DEVICE_COLLISION`).
   - Entity Graph Linkages: Linked device fingerprints, Tor/VPN exit IPs, and shared bank routing numbers.
3. **Manual Enforcement**: Click **Suspend Seller**, **Takedown Listings**, or **Freeze Payouts** to execute actions with instant API acknowledgment.
4. **Resolution**: Click the **Checkmark** to confirm resolved status, or the **X button** to dismiss as a false positive (which automatically updates the telemetry false-positive rate metric).

### 4. Direct REST API Interaction

#### Ingest Signal via Backend API
```bash
curl -X POST http://localhost:8080/api/v1/risk/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "sellerId": "seller_demo_01",
    "sellerName": "Demo Rogue Shop",
    "accountAgeDays": 2,
    "listingsLastHour": 85,
    "uniqueDevicesCount": 4,
    "distinctIpCount": 5,
    "payoutAccountChangedRecently": true,
    "geoMismatchCountry": true
  }'
```

#### Test Python Anomaly Model Standalone
```bash
curl -X POST http://localhost:5000/score \
  -H "Content-Type: application/json" \
  -d '{
    "seller_id": "seller_demo_01",
    "account_age_days": 2,
    "listings_last_hour": 85,
    "uniqueDevicesCount": 4,
    "distinctIpCount": 5,
    "payout_account_changed_recently": true,
    "geo_mismatch_country": true
  }'
```

#### Chaos Engineering & Model Failover Simulation
Simulate ML service downtime to verify resilient fallback:
```bash
# Toggle model to unhealthy state
curl -X POST http://localhost:5000/admin/toggle-health

# Trigger evaluation on backend - Observe fallback profiler activate seamlessly!
curl -X POST http://localhost:8080/api/v1/risk/evaluate ...
```

---

## 🛡️ CI/CD & Branching Strategy Guide

Pipelines are orchestrated in Jenkins using the shared library in [nagaraj602/jenkins-sharedlibraries](https://github.com/nagaraj602/jenkins-sharedlibraries.git).

### 1. Pull Request CI Quality Gate (`Jenkinsfile.pr`)
Every PR into `dev`, `staging`, or `master`:
- **Git Checkout**: Authenticated checkout of feature branch.
- **Unit & Integration Tests**: Hard fail on test failure (`mvn test` / `unittest` / `npm test`).
- **SonarQube Analysis**: Static analysis gating with `waitForQualityGate` (blocks merge on code smells/bugs).
- **Docker Build**: Local image build without remote push.
- **Trivy Scans**: Gated on `CRITICAL` and `HIGH` vulnerabilities across the filesystem, Dockerfile configuration, and image layers.

### 2. CD Deployment Pipeline (`Jenkinsfile`)
Runs on PR approval and merge:
- **Merge to `dev`**: Builds image, pushes to Amazon ECR, auto-deploys via Helm to `dev` namespace for microservice isolation testing.
- **Merge to `staging`**: Auto-deploys via Helm to `uat` namespace for end-to-end integration testing.
- **Merge to `master`**: Halts at an interactive **Manual Confirmation Gate** before deploying to the `prod` namespace during scheduled release windows.
