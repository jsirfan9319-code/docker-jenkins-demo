pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'jsirfan9319/docker-jenkins-demo'
    }

    stages {

        stage('Test') {
            steps {
                echo 'Jenkins pipeline is working!'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t ${DOCKER_IMAGE}:latest .'
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
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Docker Run') {
            steps {
                sh '''
                    docker rm -f docker-jenkins-demo || true
                    docker run -d --name docker-jenkins-demo ${DOCKER_IMAGE}:latest
                '''
            }
        }
    }

    post {
        success {
            echo 'GitHub -> Jenkins -> Docker Build -> Docker Hub Push -> Docker Run SUCCESS!'
        }

        failure {
            echo 'Pipeline FAILED. Check the console output.'
        }
    }
}
