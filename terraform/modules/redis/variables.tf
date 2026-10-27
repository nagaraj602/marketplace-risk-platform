variable "project_name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "redis_sg_id" { type = string }
variable "tags" { type = map(string) }
