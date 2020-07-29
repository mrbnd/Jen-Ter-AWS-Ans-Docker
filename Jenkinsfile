pipeline {
  agent {
    node {
      label 'master'
    }
  }

  stages {
    stage('Init') {
      steps {
        sh 'terraform init /tmp/jenkins'
        }
    }

     stage('Plan') {
      steps {
        sh 'terraform plan -out /tmp/jenkins/config.tfpaln /tmp/jenkins/'
        }
    }

     stage('Apply') {
      steps {
        sh 'terraform apply -input=false /tmp/jenkins/config.tfpaln'
        }
    }

  }
}

