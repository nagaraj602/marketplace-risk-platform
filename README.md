# Marketplace Seller Risk & Abuse Detection Platform

An enterprise-grade, real-time risk intelligence and automated abuse mitigation platform built for large-scale e-commerce marketplaces. The platform protects buyer trust by detecting fraudulent patterns (listing bursts, account takeovers, review manipulation, and device collisions) in near real-time, automatically enforcing takedowns on high-confidence cases, and prioritizing lower-confidence cases for Trust & Safety analysts.

---

## 🔗 Platform Repositories

The complete microservices suite, infrastructure, and CI/CD pipelines are maintained across five dedicated repositories:

| Repository | GitHub Link | Purpose & Tech Stack |
| :--- | :--- | :--- |
| **Platform & Infrastructure** | [nagaraj602/marketplace-risk-platform](https://github.com/nagaraj602/marketplace-risk-platform.git) | Terraform AWS IaC (VPC, EKS 1.37, RDS PostgreSQL 17, Redis 7.4, Jenkins), DB init scripts, Docker Compose |
| **Core Risk Backend** | [nagaraj602/marketplace-risk-backend](https://github.com/nagaraj602/marketplace-risk-backend.git) | Java 25 LTS, Spring Boot 4.1.2, JPA, Velocity Rule Engine, Risk Aggregation, Enforcement Orchestration |
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
│          Marketplace Risk Backend (Java 25 LTS)        │
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

Before attempting to set up and run the platform, verify that your development workstation meets the prerequisites below. The specific tools and credentials required depend on your chosen setup method.

### 📋 Prerequisites Matrix by Setup Method

| Requirement / Tool | Method 1: Docker Compose (Recommended) | Method 2: Manual Local Build (From Source) | Method 3: Cloud AWS Production (Terraform + EKS) | Minimum Required Version |
| :--- | :---: | :---: | :---: | :--- |
| **Git** | ✅ Required | ✅ Required | ✅ Required | `git 2.40+` |
| **Docker Engine & Daemon** | ✅ Required | ⚡ Optional (for DBs) | ✅ Required (image builds) | `Docker 24.0+` |
| **Docker Compose** | ✅ Required | ❌ Not Needed | ❌ Not Needed | `Compose v2.20+` |
| **AWS CLI v2** | ❌ Not Needed | ❌ Not Needed | ✅ Required | `aws-cli 2.15+` |
| **AWS IAM Credentials / Keys** | ❌ Not Needed | ❌ Not Needed | ✅ Required | Access Key, Secret Key, Region |
| **Terraform CLI** | ❌ Not Needed | ❌ Not Needed | ✅ Required | `Terraform 1.5+` (v1.17+ tested) |
| **kubectl** | ❌ Not Needed | ❌ Not Needed | ✅ Required | `v1.35 - v1.37` (EKS 1.37 match) |
| **Helm** | ❌ Not Needed | ❌ Not Needed | ✅ Required | `Helm v3.12+` or `v4` |
| **Java JDK** | ❌ Not Needed (in Docker) | ✅ Required | ❌ Not Needed (in CI/CD) | `OpenJDK 25` / `Temurin 25 LTS` |
| **Apache Maven** | ❌ Not Needed (in Docker) | ✅ Required | ❌ Not Needed (in CI/CD) | `Maven 3.9+` |
| **Python & venv** | ❌ Not Needed (in Docker) | ✅ Required | ❌ Not Needed (in CI/CD) | `Python 3.15.2+` |
| **Node.js & npm** | ❌ Not Needed (in Docker) | ✅ Required | ❌ Not Needed (in CI/CD) | `Node 24 LTS` & `npm 10+` |
| **PostgreSQL Client (`psql`)** | ❌ Not Needed (automated) | ✅ Required | ❌ Not Needed | `PostgreSQL 17.x` |

---

### 1. Hardware & System Sizing

- **Operating System**: Linux (Ubuntu 22.04 / 24.04 recommended), macOS (Apple Silicon or Intel), or Windows 10/11 with WSL2 (Ubuntu).
- **CPU**: 4 physical or virtual cores minimum.
- **Memory (RAM)**:
  - **Method 1 (Docker Compose)**: 8 GB minimum; 16 GB recommended to smoothly run Spring Boot, FastAPI, Vite/Express, Redis, and PostgreSQL concurrently.
  - **Method 2 (Local Development)**: 8 GB minimum.
  - **Method 3 (Cloud Deployments)**: 4 GB local workstation RAM (workloads execute on AWS EKS EC2 worker nodes).
- **Disk Storage**: At least 25 GB of free disk space (for Docker layer caches, Maven `.m2` repository, Python wheels, `node_modules`, and Terraform provider plugins).
- **Network**: Outbound access to Docker Hub, Maven Central, PyPI, npm registry, and AWS API endpoints.

---

### 2. Containerization Engine (Required for Method 1 & Local Testing)

Docker provides isolated container runtimes for all microservices, databases, and caches.

- **Installation**:
  - **Linux**: Install [Docker Engine](https://docs.docker.com/engine/install/) and the `docker-compose-plugin`.
  - **macOS / Windows**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/) and ensure Docker Desktop has at least 8 GB RAM and 4 CPUs allocated under *Settings > Resources*.
- **Verification Commands**:
  ```bash
  # Check Docker daemon and client
  docker --version
  # Expected: Docker version 24.0.0+ (or 26/27+)

  # Check Docker Compose v2
  docker compose version
  # Expected: Docker Compose version v2.20.0+

  # Verify Docker daemon is actively running
  docker info
  ```

---

### 3. AWS CLI & IAM Credentials (Required for Method 3: Cloud AWS Production)

Deploying the infrastructure using Terraform and managing the Amazon EKS cluster requires authenticated AWS API access with adequate IAM permissions.

#### A. AWS CLI v2 Installation
Install the official AWS CLI v2 following the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
```bash
aws --version
# Expected: aws-cli/2.15.0+ Python/3.11+
```

#### B. Required AWS IAM Credentials
You must possess an active AWS IAM user or assumed role credentials containing:
1. **AWS Access Key ID**: e.g., `AKIAIOSFODNN7EXAMPLE`
2. **AWS Secret Access Key**: e.g., `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
3. **AWS Default Region**: e.g., `ap-south-1` (Mumbai), `us-east-1` (N. Virginia), or `us-west-2` (Oregon)
4. *(Optional)* **AWS Session Token**: Required if you are authenticating via AWS SSO, AWS Organizations Identity Center, or AWS STS assumed role sessions.

#### C. Configuring AWS Credentials
Configure your credentials locally via the interactive CLI or environment variables:

**Option 1: Interactive Configuration (Stored in `~/.aws/credentials`)**
```bash
aws configure
# AWS Access Key ID [None]: AKIA...
# AWS Secret Access Key [None]: wJalrX...
# Default region name [None]: ap-south-1
# Default output format [None]: json
```

**Option 2: Environment Variables (Ideal for CI/CD and Temporary Sessions)**
```bash
export AWS_ACCESS_KEY_ID="AKIAIOSFODNN7EXAMPLE"
export AWS_SECRET_ACCESS_KEY="wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
export AWS_DEFAULT_REGION="ap-south-1"
# If using temporary STS credentials:
export AWS_SESSION_TOKEN="AQoDYXdzEJr1..."
```

#### D. Verifying Active AWS Identity
Verify that your credentials are valid and active before running Terraform:
```bash
aws sts get-caller-identity
```
*Expected Output:*
```json
{
    "UserId": "AIDAS6OQ...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/platform-deployer"
}
```

#### E. Mandatory AWS IAM Permissions & Policies
The provisioning IAM user or role must have policies granting permission to create and manage the following AWS services:
- **Amazon EKS**: `AmazonEKSClusterPolicy`, `AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy` (or `eks:*`)
- **Amazon VPC & EC2**: `AmazonVPCFullAccess` (VPC, Subnets, Internet Gateways, NAT Gateways, Elastic IPs, Security Groups, Route Tables)
- **Amazon RDS**: `AmazonRDSFullAccess` (PostgreSQL 17 DB instances, DB subnet groups, parameter groups)
- **Amazon ElastiCache**: `AmazonElastiCacheFullAccess` (Redis 7.4 replication groups, cache subnet groups)
- **Amazon ECR**: `AmazonEC2ContainerRegistryFullAccess` (Container repository creation and image pushes)
- **AWS IAM**: `iam:CreateRole`, `iam:AttachRolePolicy`, `iam:PassRole`, `iam:CreateOpenIDConnectProvider`, `iam:CreateInstanceProfile`
- **AWS KMS**: `AWSKeyManagementServicePowerUser` (KMS customer managed keys for EKS secrets envelope encryption)

---

### 4. Infrastructure as Code & Kubernetes Tooling (Required for Method 3)

#### A. Terraform CLI
- **Version**: Terraform `v1.5.0` or later (tested with Terraform `v1.17.0` and AWS Provider `~> 6.70.0`).
- **Verification**:
  ```bash
  terraform --version
  # Expected: Terraform v1.5.0+ (or v1.17+)
  ```

#### B. kubectl (Kubernetes Control CLI)
- **Version**: `kubectl` v1.35+ (matches Amazon EKS cluster version `1.37`).
- **Verification**:
  ```bash
  kubectl version --client --output=yaml
  ```

#### C. Helm (Kubernetes Package Manager)
- **Version**: Helm `v3.12.0` or later (or `v4`).
- **Verification**:
  ```bash
  helm version
  # Expected: version.BuildInfo{Version:"v3.17.0", ...}
  ```

---

### 5. Programming Language Runtimes & SDKs (Required for Method 2: Manual Local Build)

If you plan to build and run the microservices directly on your host machine without Docker:

#### A. Java 25 LTS & Maven 3.9+ (For Core Risk Backend)
- **JDK**: Eclipse Temurin 25 or OpenJDK 25 LTS
- **Build Tool**: Apache Maven 3.9+ (configured with `JAVA_HOME` pointing to Java 25)
- **Verification**:
  ```bash
  java -version
  # Expected: openjdk version "25.0.x"
  javac -version
  # Expected: javac 25.0.x
  mvn -version
  # Expected: Apache Maven 3.9.x running on Java 25.0.x
  ```

#### B. Python 3.15.2+ & Pip (For ML Anomaly Scoring Service)
- **Python**: Python 3.15.2+ with `venv` module
- **Verification**:
  ```bash
  python3 --version
  # Expected: Python 3.15.2
  python3 -m pip --version
  # Expected: pip 24.x+
  ```

#### C. Node.js 24 LTS & npm 10+ (For Trust & Safety Console Frontend)
- **Runtime**: Node.js 24 LTS (Active LTS)
- **Package Manager**: npm 10+
- **Verification**:
  ```bash
  node -v
  # Expected: v24.x.x
  npm -v
  # Expected: 10.x.x
  ```

#### D. PostgreSQL Client (`psql`)
- **Version**: PostgreSQL 17 client utilities for schema initialization
- **Verification**:
  ```bash
  psql --version
  # Expected: psql (PostgreSQL) 17.x
  ```

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
- **Trust & Safety Portal**: [http://localhost:8280](http://localhost:8280)
- **Risk Backend API**: [http://localhost:8281](http://localhost:8281)
- **Actuator Health**: [http://localhost:8281/actuator/health](http://localhost:8281/actuator/health)
- **ML Anomaly Model API & Swagger Docs**: [http://localhost:8282/docs](http://localhost:8282/docs)
- **PostgreSQL Database**: `localhost:5432` (`marketplace_risk`)
- **Redis Cache**: `localhost:6379`

---

### Method 2: Manual Standalone Development Setup

If you wish to run each microservice directly on your host:

#### Step 1: Start PostgreSQL and Redis
```bash
docker run -d --name risk-postgres -p 5432:5432 -e POSTGRES_PASSWORD=postgrespassword postgres:17-alpine
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

# Start API server on port 8282
python3 app.py
```

#### Step 3: Start the Spring Boot Backend Service
```bash
cd marketplace-risk-backend
# Run unit & integration tests
mvn clean test

# Start service on port 8281
mvn spring-boot:run
```

#### Step 4: Start the Frontend Trust & Safety Console
```bash
cd marketplace-risk-frontend
npm install
npm run build
node server.js
# Or start interactive Vite dev server (port 8280):
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
Open your web browser at **[http://localhost:8280](http://localhost:8280)**.
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
curl -X POST http://localhost:8281/api/v1/risk/evaluate \
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
curl -X POST http://localhost:8282/score \
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
curl -X POST http://localhost:8282/admin/toggle-health

# Trigger evaluation on backend - Observe fallback profiler activate seamlessly!
curl -X POST http://localhost:8281/api/v1/risk/evaluate ...
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
