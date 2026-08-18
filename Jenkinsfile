pipeline {
    agent any

    environment {
        APP_NAME = 'docker-jenkins-demo'
        APP_PORT = '5000'
    }

    stages {

        stage('Test') {
            steps {
                echo 'Jenkins pipeline is working!'
            }
        }

stage('Terraform Destroy Previous') {
    steps {
        script {
            if (fileExists('terraform-aws-project/terraform.tfstate')) {
                dir('terraform-aws-project') {
                    sh '''
                        set -e
                        SSH_CIDR=$(curl -4 -s ifconfig.me)/32
                        /snap/bin/terraform destroy -input=false -auto-approve -var="ssh_allowed_cidr=$SSH_CIDR" || true
                    '''
                }
            } else {
                echo "No previous state found, skipping destroy."
            }
        }
    }
}

        stage('Terraform Checkout') {
            steps {
                sh '''
                    rm -rf terraform-aws-project
                    git clone https://github.com/jsirfan9319-code/terraform-aws-project.git terraform-aws-project
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                dir('terraform-aws-project') {
                    sh '''
                        /snap/bin/terraform init -input=false
                    '''
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform-aws-project') {
                    sh '''
                        /snap/bin/terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform-aws-project') {
                    sh '''
                        set -e

                        SSH_CIDR=$(curl -4 -s ifconfig.me)/32

                        echo "Jenkins public IP:"
                        echo "$SSH_CIDR"

                        /snap/bin/terraform plan \
                            -input=false \
                            -var="ssh_allowed_cidr=$SSH_CIDR"
                    '''
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('terraform-aws-project') {
                    sh '''
                        set -e

                        SSH_CIDR=$(curl -4 -s ifconfig.me)/32

                        echo "Applying Terraform infrastructure..."

                        /snap/bin/terraform apply \
                            -input=false \
                            -auto-approve \
                            -var="ssh_allowed_cidr=$SSH_CIDR"
                    '''

                    script {
                        env.DEPLOY_HOST = sh(
                            script: '/snap/bin/terraform output -raw ec2_public_ip',
                            returnStdout: true
                        ).trim()

                        echo "Terraform EC2 public IP: ${env.DEPLOY_HOST}"
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    set -e

                    echo "Building Docker image..."

                    docker build \
                        -t ${APP_NAME}:latest \
                        .

                    echo "Docker image built successfully."

                    docker images ${APP_NAME}
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-deploy-key-file',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Deploying to EC2"
                        echo "========================================"

                        echo "EC2 Host: ${DEPLOY_HOST}"
                        echo "SSH User: ${SSH_USER}"

                        echo "Preparing Docker image..."

                        docker save ${APP_NAME}:latest \
                            -o ${APP_NAME}.tar

                        echo "Transferring Docker image to ${DEPLOY_HOST}..."

                        scp -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ${APP_NAME}.tar \
                            ${SSH_USER}@${DEPLOY_HOST}:/tmp/${APP_NAME}.tar

                        echo "Docker image transferred successfully."

                        echo "Connecting to EC2..."

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ${SSH_USER}@${DEPLOY_HOST} << EOF

                            set -e

                            echo "Loading Docker image..."

                            docker load \
                                -i /tmp/${APP_NAME}.tar

                            echo "Stopping old container..."

                            docker stop ${APP_NAME} 2>/dev/null || true

                            echo "Removing old container..."

                            docker rm ${APP_NAME} 2>/dev/null || true

                            echo "Starting new container..."

                            docker run -d \
                                --name ${APP_NAME} \
                                -p ${APP_PORT}:${APP_PORT} \
                                --restart unless-stopped \
                                ${APP_NAME}:latest

                            echo "Removing temporary Docker image file..."

                            rm -f /tmp/${APP_NAME}.tar

                            echo "Checking running container..."

                            docker ps \
                                --filter "name=${APP_NAME}"

                            echo "Deployment on EC2 completed."

EOF

                        echo "Removing local Docker tar file..."

                        rm -f ${APP_NAME}.tar

                        echo "========================================"
                        echo "EC2 deployment completed"
                        echo "========================================"
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-deploy-key-file',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "========================================"
                        echo "Verifying Deployment"
                        echo "========================================"

                        sleep 5

                        echo "Checking Docker container..."

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ${SSH_USER}@${DEPLOY_HOST} \
                            "docker ps --filter name=${APP_NAME}"

                        echo "Testing application from EC2..."

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ${SSH_USER}@${DEPLOY_HOST} \
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
    }

    post {

        success {
            echo '''
========================================
PIPELINE SUCCESS
========================================
Docker image built successfully.
Terraform infrastructure deployed.
Docker application deployed to EC2.
Application health check passed.
========================================
'''
            echo "Application URL: http://${DEPLOY_HOST}:${APP_PORT}"
        }

        failure {
            echo '''
========================================
DEPLOYMENT FAILED
========================================
Check the failed stage in Console Output.
========================================
'''
        }

        always {
            echo "Jenkins pipeline completed."
        }
    }
}
