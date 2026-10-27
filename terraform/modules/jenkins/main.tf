data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_iam_role" "jenkins_master" {
  name = "${var.project_name}-jenkins-master-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "jenkins_master" {
  name = "${var.project_name}-jenkins-profile"
  role = aws_iam_role.jenkins_master.name
}

resource "aws_instance" "jenkins_master" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.large"
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.jenkins_master.name
  key_name             = var.key_name

  tags = merge(var.tags, {
    Name = "${var.project_name}-jenkins-master"
  })
}
