pipeline {
    agent any

    environment {
        DEPLOY_HOST = '13.233.4.91'
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

        stage('Terraform Apply') {
            steps {
                dir('terraform-aws-project') {
                    sh '''
                        SSH_CIDR=$(curl -4 -s ifconfig.me)/32
                        /snap/bin/terraform apply \
                        -auto-approve \
                        -input=false \
                        -var="ssh_allowed_cidr=$SSH_CIDR"
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build -t ${APP_NAME}:latest .
                '''
            }
        }

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'ec2-deploy-key-file',
                        variable: 'SSH_KEY'
                    )
                ]) {
                    sh '''
                        echo "Preparing Docker image..."

                        docker save ${APP_NAME}:latest -o ${APP_NAME}.tar

                        echo "Transferring Docker image to ${DEPLOY_HOST}..."

                        scp -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ${APP_NAME}.tar \
                            ubuntu@${DEPLOY_HOST}:/tmp/${APP_NAME}.tar

                        echo "Deploying application..."

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ubuntu@${DEPLOY_HOST} \
                            "docker load -i /tmp/${APP_NAME}.tar && \
                             docker rm -f ${APP_NAME} || true"

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ubuntu@${DEPLOY_HOST} \
                            "docker run -d \
                             --name ${APP_NAME} \
                             -p ${APP_PORT}:${APP_PORT} \
                             ${APP_NAME}:latest"

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ubuntu@${DEPLOY_HOST} \
                            "rm -f /tmp/${APP_NAME}.tar"

                        rm -f ${APP_NAME}.tar

                        echo "Deployment completed successfully."
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'ec2-deploy-key-file',
                        variable: 'SSH_KEY'
                    )
                ]) {
                    sh '''
                        echo "Checking Docker container..."

                        sleep 5

                        ssh -i "$SSH_KEY" \
                            -o StrictHostKeyChecking=no \
                            ubuntu@${DEPLOY_HOST} \
                            "docker ps --filter name=${APP_NAME}"

                        echo "Testing application..."

                        curl -f http://${DEPLOY_HOST}:${APP_PORT}

                        echo "Application verification successful."
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '========================================'
            echo 'DEPLOYMENT SUCCESSFUL'
            echo '========================================'
            echo "Application: ${APP_NAME}"
            echo "Server: ${DEPLOY_HOST}"
            echo "Port: ${APP_PORT}"
            echo "URL: http://${DEPLOY_HOST}:${APP_PORT}"
        }

        failure {
            echo '========================================'
            echo 'DEPLOYMENT FAILED'
            echo '========================================'
            echo 'Check the failed stage in Console Output.'
        }
    }
}
