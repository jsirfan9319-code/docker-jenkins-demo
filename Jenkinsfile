pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'jsirfan9319/docker-jenkins-demo'
    }

    stages {

        stage('Test') {
            steps {
                echo 'Jenkins pipeline is working!'
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Docker Image: ${DOCKER_IMAGE}:build-${BUILD_NUMBER}"
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                      -t ${DOCKER_IMAGE}:build-${BUILD_NUMBER} \
                      -t ${DOCKER_IMAGE}:latest .
                '''
            }
        }

        stage('Docker Hub Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-credentials',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login \
                          -u "$DOCKER_USERNAME" \
                          --password-stdin

                        docker push ${DOCKER_IMAGE}:build-${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    echo "Deploying Docker image..."

                    docker rm -f docker-jenkins-demo-container || true

                    docker pull ${DOCKER_IMAGE}:build-${BUILD_NUMBER}

                    docker run -d \
                        --name docker-jenkins-demo-container \
                        -p 5000:5000 \
                        --restart unless-stopped \
                        ${DOCKER_IMAGE}:build-${BUILD_NUMBER}
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                    sleep 5

                    curl -f http://localhost:5000

                    echo ""
                    echo "Application health check PASSED!"
                '''
            }
        }
    }

    post {
        success {
            echo "=========================================="
            echo "PIPELINE SUCCESS"
            echo "Image: ${DOCKER_IMAGE}:build-${BUILD_NUMBER}"
            echo "Latest: ${DOCKER_IMAGE}:latest"
            echo "=========================================="
        }

        failure {
            echo "Pipeline FAILED. Check the console output."
        }
    }
}
