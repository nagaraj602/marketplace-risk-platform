module "networking" {
  source = "./modules/vpc"

  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  tags         = var.tags
}

module "eks" {
  source = "./modules/eks"

  cluster_name       = "${var.project_name}-eks"
  kubernetes_version = var.kubernetes_version
  subnet_ids         = module.networking.private_subnet_ids
  eks_nodes_sg_id    = module.networking.eks_nodes_sg_id
  node_instance_type = var.node_instance_type
  tags               = var.tags
}

module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  db_name      = var.db_name
  subnet_ids   = module.networking.data_subnet_ids
  db_sg_id     = module.networking.rds_sg_id
  tags         = var.tags
}

module "redis" {
  source = "./modules/redis"

  project_name = var.project_name
  subnet_ids   = module.networking.data_subnet_ids
  redis_sg_id  = module.networking.redis_sg_id
  tags         = var.tags
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/id_rsa_${var.project_name}.pem"
  file_permission = "0400"
}

module "bastion" {
  source = "./modules/bastion"

  project_name  = var.project_name
  subnet_id     = element(module.networking.public_subnet_ids, 0)
  bastion_sg_id = module.networking.bastion_sg_id
  key_name      = aws_key_pair.generated.key_name
  tags          = var.tags
}

module "jenkins" {
  source = "./modules/jenkins"

  project_name = var.project_name
  subnet_id    = element(module.networking.private_subnet_ids, 0)
  key_name     = aws_key_pair.generated.key_name
  tags         = var.tags
}
