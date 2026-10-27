output "jenkins_instance_id" { value = aws_instance.jenkins_master.id }
output "jenkins_private_ip" { value = aws_instance.jenkins_master.private_ip }
