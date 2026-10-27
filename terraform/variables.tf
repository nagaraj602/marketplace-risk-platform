variable "project_name" {
  description = "Project name prefix used for resource naming"
  type        = string
  default     = "marketplace-risk"
}

variable "region" {
  description = "AWS target deployment region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes Version (latest stable supported)"
  type        = string
  default     = "1.32"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "db_name" {
  description = "Initial PostgreSQL database name"
  type        = string
  default     = "marketplace_risk"
}

variable "tags" {
  description = "Common tags applied to all provisioned cloud resources"
  type        = map(string)
  default = {
    Project     = "Marketplace-Risk-Platform"
    ManagedBy   = "Terraform"
    Environment = "production"
    Owner       = "Nagaraj"
  }
}
