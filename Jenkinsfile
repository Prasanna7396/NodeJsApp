pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID="835839292917"
        AWS_DEFAULT_REGION="us-east-1" 
        IMAGE_REPO_NAME="jenkins-nodejs"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        }
	tools {
		jdk 'jdk11'
	}
    stages {
        stage('GetCode') { 
            steps {
		script{
		     properties([pipelineTriggers([pollSCM('H/1 * * * *')])])
		  } 
                git branch: 'main', credentialsId: 'myGitHub', url: 'https://github.com/Prasanna7396/NodeJsApp.git'
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
        //stage('SonarQube Analysis'){
        //     steps {
        //       withSonarQubeEnv('sonarqube-8.9.2') { 
	//		 sh "mvn sonar:sonar -Dsonar.projectKey=NodeApp"
        //    }
        //  }
        // }	
        stage('Docker Build'){
	  steps {
           script {
            sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
            }  
          }
          post {
	   success {
	      script {
               dockerImage = docker.build "${IMAGE_REPO_NAME}:${IMAGE_TAG}"
              }
	   }
	  }
	}
        stage('Pushing docker image to ECR') {
         steps{  
          script{
                sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
          }
        }
      }
    }
}
