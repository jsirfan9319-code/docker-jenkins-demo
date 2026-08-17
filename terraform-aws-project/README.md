# Terraform AWS DevOps Project

This project provisions AWS infrastructure using Terraform.

## Infrastructure

- AWS VPC
- Public Subnet
- Internet Gateway
- Public Route Table
- Security Group
- EC2 Instance

## Technologies

- AWS
- Terraform
- Linux
- Git
- GitHub

## Architecture

Terraform creates a public AWS VPC with an EC2 instance accessible through the Internet Gateway.

```text
Internet
   |
Internet Gateway
   |
Public Route Table
   |
Public Subnet
   |
Security Group
   |
EC2 Instance

## Terraform Commands

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
