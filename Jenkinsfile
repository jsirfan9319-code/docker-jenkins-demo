pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'jsirfan9319/docker-jenkins-demo'
        IMAGE_TAG = "build-${BUILD_NUMBER}"
    }

    stages {

        stage('Test') {
            steps {
                echo "Jenkins pipeline is working!"
                echo "Build Number: ${BUILD_NUMBER}"
                echo "Docker Image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    docker build \
                    -t ${DOCKER_IMAGE}:${IMAGE_TAG} \
                    -t ${DOCKER_IMAGE}:latest \
                    .
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

                        docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
                        docker push ${DOCKER_IMAGE}:latest

                        docker logout
                    '''
                }
            }
        }

        stage('Docker Run') {
            steps {
                sh '''
                    docker rm -f docker-jenkins-demo-container || true

                    docker run -d \
                        --name docker-jenkins-demo-container \
                        -p 5000:5000 \
                        --restart unless-stopped \
                        ${DOCKER_IMAGE}:${IMAGE_TAG}

                    sleep 5

                    curl -f http://localhost:5000
                '''
            }
        }
    }

    post {
        success {
            echo "=========================================="
            echo "PIPELINE SUCCESS"
            echo "Image: ${DOCKER_IMAGE}:${IMAGE_TAG}"
            echo "Latest: ${DOCKER_IMAGE}:latest"
            echo "=========================================="
        }

        failure {
            echo "Pipeline FAILED. Check the console output."
        }
    }
}
