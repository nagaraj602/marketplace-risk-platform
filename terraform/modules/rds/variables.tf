variable "project_name" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string; default = "riskuser" }
variable "db_password" { type = string; default = "riskpass123" }
variable "subnet_ids" { type = list(string) }
variable "db_sg_id" { type = string }
variable "tags" { type = map(string) }
