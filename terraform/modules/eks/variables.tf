variable "cluster_name" { type = string }
variable "kubernetes_version" { type = string }
variable "subnet_ids" { type = list(string) }
variable "eks_nodes_sg_id" { type = string }
variable "node_instance_type" { type = string }
variable "tags" { type = map(string) }
