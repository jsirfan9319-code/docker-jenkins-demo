pipeline {
    agent any

    environment {
        DEPLOY_HOST = '65.2.184.41'
        APP_NAME = 'docker-jenkins-demo'
        APP_PORT = '5000'
    }

    stages {

        stage('Test') {
            steps {
                echo 'Jenkins pipeline is working!'
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
                    sh '/snap/bin/terraform init -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('terraform-aws-project') {
                    sh '/snap/bin/terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('terraform-aws-project') {
                    sh '''
                        SSH_CIDR=$(curl -4 -s ifconfig.me)/32
                        /snap/bin/terraform plan \
                          -input=false \
                          -var="ssh_allowed_cidr=$SSH_CIDR"
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${APP_NAME}:latest .'
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-deploy-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "Transferring Docker image to ${DEPLOY_HOST}..."

                        docker save ${APP_NAME}:latest | gzip | \
                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ${SSH_USER}@${DEPLOY_HOST} \
                            'gunzip | docker load'

                        echo "Starting application on EC2..."

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ${SSH_USER}@${DEPLOY_HOST} \
                            "
                                docker rm -f ${APP_NAME} 2>/dev/null || true
                                docker run -d \
                                    --name ${APP_NAME} \
                                    -p ${APP_PORT}:${APP_PORT} \
                                    ${APP_NAME}:latest
                            "

                        echo "Deployment completed successfully."
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-deploy-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    sh '''
                        sleep 5

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ${SSH_USER}@${DEPLOY_HOST} \
                            "docker ps --filter name=${APP_NAME}"

                        echo "Testing application..."
                        curl -f http://${DEPLOY_HOST}:${APP_PORT}
                    '''
                }
            }
        }
    }
}
