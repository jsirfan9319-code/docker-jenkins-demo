pipeline {
    agent any

    stages {
        stage('Test') {
            steps {
                echo 'Jenkins pipeline is working!'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t docker-jenkins-demo .'
            }
        }

        stage('Docker Run') {
            steps {
                sh 'docker run --rm docker-jenkins-demo'
            }
        }
    }
}
