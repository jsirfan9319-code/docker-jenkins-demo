pipeline {
    agent any

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
                        /snap/bin/terraform plan -input=false -var="ssh_allowed_cidr=$SSH_CIDR"
                    '''
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                dir('terraform-aws-project') {
                    sh '''
                        SSH_CIDR=$(curl -4 -s ifconfig.me)/32
                        /snap/bin/terraform apply -auto-approve -input=false -var="ssh_allowed_cidr=$SSH_CIDR"
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t docker-jenkins-demo .'
            }
        }

        stage('Docker Run') {
            steps {
                sh '''
                    docker rm -f docker-jenkins-demo || true
                    docker run -d --name docker-jenkins-demo -p 5000:5000 docker-jenkins-demo
                    sleep 5
                    curl -f http://localhost:5000
                '''
            }
        }
    }
}
    
