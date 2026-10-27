output "vpc_id" {
  description = "ID of the provisioned VPC"
  value       = module.networking.vpc_id
}

output "eks_cluster_name" {
  description = "Name of the Amazon EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint URL for Amazon EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  description = "Connection endpoint for Amazon RDS PostgreSQL"
  value       = module.rds.endpoint
}

output "redis_endpoint" {
  description = "Primary endpoint for AWS ElastiCache Redis velocity counter cluster"
  value       = module.redis.endpoint
}

output "bastion_public_ip" {
  description = "Public IP of Bastion management host"
  value       = module.bastion.public_ip
}
