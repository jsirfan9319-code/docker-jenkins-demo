## 🔄 CI/CD Pipeline

The Jenkins pipeline performs the following stages:

1. Test
2. Terraform Init
3. Terraform Validate
4. Terraform Plan
5. Terraform Apply
6. Get EC2 Host
7. Verify SSH
8. Docker Build
9. Docker Test
10. Install Docker on EC2
11. Deploy to EC2
12. Verify Deployment

## 🛠️ Technologies Used

- AWS EC2
- Terraform
- Jenkins
- Docker
- Git
- GitHub
- GitHub Webhooks
- Python
- Flask
- Ubuntu Linux
- SSH
- Bash

## ☁️ AWS Infrastructure

Terraform is used to manage the AWS infrastructure required for the deployment.

The project uses:

- Amazon EC2
- VPC
- Public Subnet
- Security Group
- SSH access
- Public IP address

## 🐳 Docker Deployment

Jenkins builds the Docker image and tests it before deployment.

The image is then transferred to the AWS EC2 instance using SCP.

On EC2, the pipeline:

1. Loads the Docker image
2. Removes the previous container
3. Starts the new container
4. Verifies the running container

## 🔗 GitHub Webhook

A GitHub Webhook automatically triggers Jenkins when code is pushed to the repository.

```text
Git Push
   ↓
GitHub
   ↓
GitHub Webhook
   ↓
Jenkins
   ↓
Automated CI/CD Pipeline
   ↓
AWS EC2
```
## 🧪 Deployment Verification

After deployment, Jenkins verifies the Docker container and checks that the application is responding successfully.

The deployed application returns:

```text
Hello from AWS DevOps! Version 4 - Automatic CI/CD deployment is working!
```
## ✅ Project Status

The CI/CD pipeline has been successfully implemented and tested.

- GitHub Webhook triggers Jenkins automatically
- Jenkins pipeline executes successfully
- Terraform manages AWS infrastructure
- Docker image is built and deployed
- Application is running on AWS EC2
- Deployment verification passes successfully
- Jenkins Build #100 completed with `Finished: SUCCESS`

### Live Application

The deployed Flask application is available on AWS EC2.

```text
Hello from AWS DevOps! Version 4 - Automatic CI/CD deployment is working!
```
