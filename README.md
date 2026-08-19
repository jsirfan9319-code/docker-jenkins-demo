# AWS DevOps CI/CD Deployment Pipeline

## 📌 Project Overview

This project demonstrates an end-to-end DevOps CI/CD pipeline that automatically builds, tests, and deploys a Dockerized application to AWS EC2.

A code change pushed to GitHub triggers a Jenkins pipeline through a GitHub Webhook. Jenkins uses Terraform to provision/manage the AWS infrastructure, builds the Docker image, transfers it to the EC2 server, deploys the container, and performs an application health check.

## 🏗️ Architecture

```text
Developer
    |
    | git push
    v
GitHub Repository
    |
    | GitHub Webhook
    v
Jenkins
    |
    +----------------------+
    |                      |
    v                      v
Terraform              Docker Build
    |                      |
    v                      v
AWS EC2 <------------- Docker Image
    |
    v
Docker Container
    |
    v
Flask Application
    |
    v
HTTP Response
