output "vpc_id" {
  description = "ID of the Terraform VPC"
  value       = aws_vpc.devops_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.devops_sg.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.devops_ec2.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.devops_ec2.public_ip
}
