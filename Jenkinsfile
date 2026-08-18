pipeline {

    agent any

    environment {
        SSH_USER = 'ubuntu'
        APP_NAME = 'docker-jenkins-demo'
        APP_PORT = '5000'

        SSH_KEY = '/var/lib/jenkins/.ssh/jenkins-deploy-key-new.pem'

        TERRAFORM_DIR = 'terraform-aws-project'
    }

    stages {

        stage('Test') {
            steps {
                echo 'Jenkins pipeline is working!'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Terraform Init"
                        echo "========================================"

                        /snap/bin/terraform init -input=false
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Terraform Validate"
                        echo "========================================"

                        /snap/bin/terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Terraform Plan"
                        echo "========================================"

                        SSH_CIDR="$(curl -4 -s ifconfig.me)/32"

                        echo "SSH CIDR: ${SSH_CIDR}"

                        /snap/bin/terraform plan \
                            -input=false \
                            -var="ssh_allowed_cidr=${SSH_CIDR}"
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Terraform Apply"
                        echo "========================================"

                        SSH_CIDR="$(curl -4 -s ifconfig.me)/32"

                        echo "SSH CIDR: ${SSH_CIDR}"

                        /snap/bin/terraform apply \
                            -input=false \
                            -auto-approve \
                            -var="ssh_allowed_cidr=${SSH_CIDR}"

                        echo ""
                        echo "Terraform apply completed"
                    '''
                }
            }
        }

        stage('Get EC2 Host') {
            steps {
                script {

                    env.DEPLOY_HOST = sh(
                        script: """
                            cd ${TERRAFORM_DIR}
                            /snap/bin/terraform output -raw ec2_public_ip
                        """,
                        returnStdout: true
                    ).trim()

                    echo "========================================"
                    echo "Terraform EC2 Public IP"
                    echo "========================================"
                    echo "EC2 Host: ${env.DEPLOY_HOST}"
                }
            }
        }

        stage('Verify SSH') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "Testing Jenkins → EC2 SSH"
                    echo "========================================"

                    echo "SSH User: ${SSH_USER}"
                    echo "EC2 Host: ${DEPLOY_HOST}"

                    test -f "${SSH_KEY}"

                    test -r "${SSH_KEY}"

                    ssh \
                        -i "${SSH_KEY}" \
                        -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -o ConnectTimeout=15 \
                        "${SSH_USER}@${DEPLOY_HOST}" \
                        "echo JENKINS_SSH_WORKING"

                    echo "SSH connection successful"
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "Building Docker Image"
                    echo "========================================"

                    docker build \
                        -t "${APP_NAME}:latest" \
                        .

                    echo "Docker image built successfully"

                    docker images "${APP_NAME}"
                '''
            }
        }

        stage('Docker Test') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "Testing Docker Image"
                    echo "========================================"

                    docker rm -f "${APP_NAME}-test" 2>/dev/null || true

                    docker run -d \
                        --name "${APP_NAME}-test" \
                        -p 5001:${APP_PORT} \
                        "${APP_NAME}:latest"

                    sleep 5

                    curl -f http://localhost:5001

                    docker rm -f "${APP_NAME}-test"

                    echo "Docker test passed"
                '''
            }
        }

    stage('Install Docker on EC2') {
        steps {
            sh '''
                set -e

                echo "========================================"
                echo "Preparing Docker on EC2"
                echo "========================================"

                ssh \
                    -i "${SSH_KEY}" \
                    -o StrictHostKeyChecking=no \
                    -o UserKnownHostsFile=/dev/null \
                    -o ConnectTimeout=15 \
                    "${SSH_USER}@${DEPLOY_HOST}" \
                    'if command -v docker >/dev/null 2>&1; then
                        echo "Docker is already installed"
                        docker --version
                    else
                        echo "Installing Docker..."
                        sudo apt-get update -y
                        sudo apt-get install -y docker.io
                        sudo systemctl enable --now docker
                        sudo docker --version
                    fi'

                echo "Docker is ready on EC2"
            '''
        }
    }

        stage('Deploy to EC2') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "Deploying to EC2"
                    echo "========================================"

                    echo "EC2 Host: ${DEPLOY_HOST}"
                    echo "SSH User: ${SSH_USER}"

                    echo ""
                    echo "Creating Docker image archive..."

                    docker save \
                        "${APP_NAME}:latest" \
                        -o "${APP_NAME}.tar"

                    echo "Docker archive created"

                    echo ""
                    echo "Transferring Docker image..."

                    scp \
                        -i "${SSH_KEY}" \
                        -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -o ConnectTimeout=15 \
                        "${APP_NAME}.tar" \
                        "${SSH_USER}@${DEPLOY_HOST}:/tmp/${APP_NAME}.tar"

                    echo "Docker image transferred successfully"

                    echo ""
                    echo "Deploying container..."

                    ssh \
                        -i "${SSH_KEY}" \
                        -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -o ConnectTimeout=15 \
                        "${SSH_USER}@${DEPLOY_HOST}" << EOF

                        set -e

                        echo "Connected to EC2"

                        echo "Loading Docker image..."

                        docker load \
                            -i /tmp/${APP_NAME}.tar

                        echo "Stopping old container..."

                        docker rm -f ${APP_NAME} 2>/dev/null || true

                        echo "Starting new container..."

                        docker run -d \
                            --name ${APP_NAME} \
                            --restart unless-stopped \
                            -p ${APP_PORT}:${APP_PORT} \
                            ${APP_NAME}:latest

                        echo "Removing temporary image archive..."

                        rm -f /tmp/${APP_NAME}.tar

                        echo ""
                        echo "Running containers:"
                        docker ps --filter "name=${APP_NAME}"

EOF

                    echo ""
                    echo "EC2 deployment completed successfully"
                '''
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    set -e

                    echo "========================================"
                    echo "Verifying Deployment"
                    echo "========================================"

                    sleep 5

                    echo "Checking Docker container..."

                    ssh \
                        -i "${SSH_KEY}" \
                        -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -o ConnectTimeout=15 \
                        "${SSH_USER}@${DEPLOY_HOST}" \
                        "docker ps --filter name=${APP_NAME}"

                    echo ""
                    echo "Testing application from EC2..."

                    ssh \
                        -i "${SSH_KEY}" \
                        -o StrictHostKeyChecking=no \
                        -o UserKnownHostsFile=/dev/null \
                        -o ConnectTimeout=15 \
                        "${SSH_USER}@${DEPLOY_HOST}" \
                        "curl -f http://localhost:${APP_PORT}"

                    echo ""
                    echo "========================================"
                    echo "APPLICATION HEALTH CHECK PASSED"
                    echo "========================================"

                    echo "Server: ${DEPLOY_HOST}"
                    echo "URL: http://${DEPLOY_HOST}:${APP_PORT}"
                '''
            }
        }
    }

    post {

        success {
            echo '''
========================================
DEPLOYMENT SUCCESSFUL
========================================
Application deployed successfully.
'''
        }

        failure {
            echo '''
========================================
DEPLOYMENT FAILED
========================================
Check the failed stage in Console Output.
'''
        }

        always {
            sh '''
                rm -f "${APP_NAME}.tar" 2>/dev/null || true
            '''
        }
    }
}
