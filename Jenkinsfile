pipeline {
  agent any
  environment {
    AWS_ACCOUNT_ID = "894328728902"
    AWS_DEFAULT_REGION = "us-east-1"
    IMAGE_REPO_NAME = "jenkins-nodejs"
    S3BUCKET = "terraformscripts-nodejsapp"
    REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
  }
  stages {
    stage('Git Checkout') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'myGithub', url: 'https://github.com/Prasanna7396/NodeJsApp.git']
        ]])
      }
    }
    stage('Build Application') {
      steps {
        sh 'mvn install'
      }
      post {
        success {
          echo "Now Archiving the Artifacts...."
          archiveArtifacts artifacts: '**/*.war'
        }
      }
    }
    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv('sonarqube-8.9.2') {
          sh "mvn sonar:sonar -Dsonar.projectKey=NodeApp"
        }
      }
    }
    stage('Docker Build Image') {
      steps {
        script {
          dockerImage = docker.build "${REPOSITORY_URI}:${BUILD_NUMBER}"
        }
      }
    }
    stage('Pushing Docker Image to ECR') {
      steps {
        script {
          sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
        }
      }
      post {
        success {
          script {
            sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${BUILD_NUMBER}"
          }
        }
      }
    }
    stage('Push Terraform scripts to AWS S3') {
      steps {
        withCredentials([
          [ $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "AWS_CREDENTIALS",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
          ]]){
          s3Upload acl: 'Private', bucket: "${S3BUCKET}", includePathPattern: '*.tf', workingDir: 'terraform-scripts'
        }
      }
    }
    stage('Terraform - K8s Cluster Deployment') {
      steps {
        withCredentials([
          [ $class: 'AmazonWebServicesCredentialsBinding',
            credentialsId: "AWS_CREDENTIALS",
            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']
          ]){
          sh 'cd terraform-scripts && terraform init && terraform plan && terraform apply -auto-approve'
        }
      }
    }
    stage('NodeJs application Deployment') {
      steps {
        //Adding the node in kubeconfig
        sh 'aws eks --region "${AWS_DEFAULT_REGION}" update-kubeconfig --name eks_cluster_nodejs'
        //Running k8-manifest files
        sh 'cd k8-manifest && sudo kubectl apply -f createNamespace.yml && sudo  kubectl apply -f app-deployment.yml && sudo kubectl apply -f loadbalancer-sv.yml'
      }
    }
  }
  post {
    always {
        emailext body: "Deployment Status - ${currentBuild.currentResult}: Job ${env.JOB_NAME} build ${env.BUILD_NUMBER}\n More info at: ${env.BUILD_URL}",
        recipientProviders: [[$class: 'DevelopersRecipientProvider'],[$class: 'RequesterRecipientProvider']],
        subject: "Deployment Status - ${currentBuild.currentResult}: Job ${env.JOB_NAME}"
    }
  }
}
