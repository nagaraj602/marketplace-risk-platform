-- =====================================================================
-- Marketplace Seller Risk & Abuse Detection Platform
-- Database Initialization & Schema Definition Script
-- Environments: Production, Development, Staging / UAT
-- =====================================================================

-- 1. Create Dedicated Service User
DO
$do$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'riskuser') THEN
      CREATE USER riskuser WITH ENCRYPTED PASSWORD 'riskpass123';
   END IF;
END
$do$;

-- 2. Create Target Databases
CREATE DATABASE marketplace_risk;
CREATE DATABASE marketplace_risk_dev;
CREATE DATABASE marketplace_risk_staging;

-- Grant Root Privileges
GRANT ALL PRIVILEGES ON DATABASE marketplace_risk TO riskuser;
GRANT ALL PRIVILEGES ON DATABASE marketplace_risk_dev TO riskuser;
GRANT ALL PRIVILEGES ON DATABASE marketplace_risk_staging TO riskuser;

-- =====================================================================
-- 3. PRODUCTION DATABASE INITIALIZATION
-- =====================================================================
\c marketplace_risk;

GRANT ALL ON SCHEMA public TO riskuser;

-- Sellers Master Entity Table
CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(64) PRIMARY KEY,
    seller_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    account_age_days INT DEFAULT 30,
    rating DOUBLE PRECISION DEFAULT 4.5,
    status VARCHAR(50) DEFAULT 'ACTIVE', -- ACTIVE, SUSPENDED, UNDER_REVIEW
    registered_country VARCHAR(10) DEFAULT 'US',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Real-Time Risk Cases Table
CREATE TABLE IF NOT EXISTS risk_cases (
    id BIGSERIAL PRIMARY KEY,
    seller_id VARCHAR(64) NOT NULL,
    seller_name VARCHAR(255),
    risk_score DOUBLE PRECISION NOT NULL,
    risk_tier VARCHAR(50) NOT NULL, -- CRITICAL, HIGH, ELEVATED, LOW
    status VARCHAR(50) NOT NULL,    -- PENDING, RESOLVED, DISMISSED, AUTO_ENFORCED
    anomaly_flags VARCHAR(1000),
    velocity_score DOUBLE PRECISION,
    ml_anomaly_score DOUBLE PRECISION,
    sla_deadline TIMESTAMP,
    decision_reason VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_cases_seller_id ON risk_cases(seller_id);
CREATE INDEX IF NOT EXISTS idx_cases_status ON risk_cases(status);
CREATE INDEX IF NOT EXISTS idx_cases_risk_tier ON risk_cases(risk_tier);
CREATE INDEX IF NOT EXISTS idx_cases_created_at ON risk_cases(created_at);

-- Automated & Manual Enforcement Actions Log
CREATE TABLE IF NOT EXISTS enforcement_actions (
    id BIGSERIAL PRIMARY KEY,
    case_id BIGINT,
    seller_id VARCHAR(64) NOT NULL,
    action_type VARCHAR(50) NOT NULL, -- SUSPEND_SELLER, TAKEDOWN_LISTINGS, HOLD_PAYOUT
    status VARCHAR(50) NOT NULL,      -- SUCCESS, PENDING_RETRY, FAILED
    retry_count INT DEFAULT 0,
    reason VARCHAR(500),
    initiated_by VARCHAR(50) NOT NULL, -- AUTOMATED_PIPELINE, ANALYST
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_enforce_seller_id ON enforcement_actions(seller_id);
CREATE INDEX IF NOT EXISTS idx_enforce_status ON enforcement_actions(status);

-- Permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO riskuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO riskuser;
ALTER TABLE sellers OWNER TO riskuser;
ALTER TABLE risk_cases OWNER TO riskuser;
ALTER TABLE enforcement_actions OWNER TO riskuser;

-- Production Seed Data
INSERT INTO sellers (seller_id, seller_name, email, account_age_days, rating, status, registered_country) VALUES
('seller_alpha_01', 'Prime Store Global', 'ops@primestore.com', 450, 4.9, 'ACTIVE', 'US'),
('seller_fraud_99', 'Discount Flash Deals', 'bot99@throwaway.net', 3, 2.1, 'SUSPENDED', 'RO'),
('seller_ato_54', 'Antique Relics Direct', 'support@antiquerelics.com', 720, 4.8, 'UNDER_REVIEW', 'US');

INSERT INTO risk_cases (seller_id, seller_name, risk_score, risk_tier, status, anomaly_flags, velocity_score, ml_anomaly_score, created_at) VALUES
('seller_fraud_99', 'Discount Flash Deals', 92.5, 'CRITICAL', 'AUTO_ENFORCED', 'RULE_EXCESSIVE_LISTINGS_PER_HOUR, SUSPICIOUS_MULTI_DEVICE_COLLISION', 90.0, 94.5, CURRENT_TIMESTAMP - INTERVAL '1 hour'),
('seller_ato_54', 'Antique Relics Direct', 71.0, 'HIGH', 'PENDING', 'RULE_RAPID_PAYOUT_MODIFICATION, GEOLOCATION_MISMATCH', 65.0, 76.0, CURRENT_TIMESTAMP - INTERVAL '30 minutes');

INSERT INTO enforcement_actions (case_id, seller_id, action_type, status, reason, initiated_by) VALUES
(1, 'seller_fraud_99', 'SUSPEND_SELLER', 'SUCCESS', 'Automated high confidence trigger', 'AUTOMATED_PIPELINE'),
(1, 'seller_fraud_99', 'HOLD_PAYOUT', 'SUCCESS', 'Automated high confidence trigger', 'AUTOMATED_PIPELINE');

-- =====================================================================
-- 4. DEV DATABASE INITIALIZATION
-- =====================================================================
\c marketplace_risk_dev;

GRANT ALL ON SCHEMA public TO riskuser;

CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(64) PRIMARY KEY,
    seller_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    account_age_days INT DEFAULT 30,
    rating DOUBLE PRECISION DEFAULT 4.5,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    registered_country VARCHAR(10) DEFAULT 'US',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS risk_cases (
    id BIGSERIAL PRIMARY KEY,
    seller_id VARCHAR(64) NOT NULL,
    seller_name VARCHAR(255),
    risk_score DOUBLE PRECISION NOT NULL,
    risk_tier VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    anomaly_flags VARCHAR(1000),
    velocity_score DOUBLE PRECISION,
    ml_anomaly_score DOUBLE PRECISION,
    sla_deadline TIMESTAMP,
    decision_reason VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS enforcement_actions (
    id BIGSERIAL PRIMARY KEY,
    case_id BIGINT,
    seller_id VARCHAR(64) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    retry_count INT DEFAULT 0,
    reason VARCHAR(500),
    initiated_by VARCHAR(50) NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO riskuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO riskuser;
ALTER TABLE sellers OWNER TO riskuser;
ALTER TABLE risk_cases OWNER TO riskuser;
ALTER TABLE enforcement_actions OWNER TO riskuser;

INSERT INTO sellers (seller_id, seller_name, email, account_age_days, rating, status, registered_country) VALUES
('dev_seller_01', 'Dev Test Store', 'test@dev.local', 15, 4.0, 'ACTIVE', 'US');

-- =====================================================================
-- 5. STAGING / UAT DATABASE INITIALIZATION
-- =====================================================================
\c marketplace_risk_staging;

GRANT ALL ON SCHEMA public TO riskuser;

CREATE TABLE IF NOT EXISTS sellers (
    seller_id VARCHAR(64) PRIMARY KEY,
    seller_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    account_age_days INT DEFAULT 30,
    rating DOUBLE PRECISION DEFAULT 4.5,
    status VARCHAR(50) DEFAULT 'ACTIVE',
    registered_country VARCHAR(10) DEFAULT 'US',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS risk_cases (
    id BIGSERIAL PRIMARY KEY,
    seller_id VARCHAR(64) NOT NULL,
    seller_name VARCHAR(255),
    risk_score DOUBLE PRECISION NOT NULL,
    risk_tier VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    anomaly_flags VARCHAR(1000),
    velocity_score DOUBLE PRECISION,
    ml_anomaly_score DOUBLE PRECISION,
    sla_deadline TIMESTAMP,
    decision_reason VARCHAR(1000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS enforcement_actions (
    id BIGSERIAL PRIMARY KEY,
    case_id BIGINT,
    seller_id VARCHAR(64) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL,
    retry_count INT DEFAULT 0,
    reason VARCHAR(500),
    initiated_by VARCHAR(50) NOT NULL,
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO riskuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO riskuser;
ALTER TABLE sellers OWNER TO riskuser;
ALTER TABLE risk_cases OWNER TO riskuser;
ALTER TABLE enforcement_actions OWNER TO riskuser;

\echo ''
\echo '========================================================'
\echo 'Marketplace Risk Databases & Schemas Initialized!'
\echo '  - marketplace_risk (Production)'
\echo '  - marketplace_risk_dev (Development)'
\echo '  - marketplace_risk_staging (Staging / UAT)'
\echo '========================================================'
