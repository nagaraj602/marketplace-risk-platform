resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-db-subnet-group"
  })
}

resource "aws_db_instance" "this" {
  identifier        = "${var.project_name}-db"
  allocated_storage = 50
  max_allocated_storage = 200
  storage_type      = "gp3"
  engine            = "postgres"
  engine_version    = "16.4"
  instance_class    = "db.t4g.medium"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az            = true
  skip_final_snapshot = true
  publicly_accessible = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-db"
  })
}
