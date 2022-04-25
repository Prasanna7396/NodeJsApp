pipeline {
    agent any
	options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timeout(time: 1, unit: 'HOURS')
        timestamps()
    }
    environment {
	POM_VERSION = getVersion()
        AWS_ECR_URL= "https://835839292917.dkr.ecr.us-east-1.amazonaws.com"
	AWS_ECR_REGION = 'us-east-1'
        AWS_ECS_SERVICE = 'ch-dev-user-api-service'
        AWS_ECS_TASK_DEFINITION = 'ch-dev-user-api-taskdefinition'
        AWS_ECS_COMPATIBILITY = 'FARGATE'
        AWS_ECS_NETWORK_MODE = 'awsvpc'
        AWS_ECS_CPU = '256'
        AWS_ECS_MEMORY = '512'
        AWS_ECS_CLUSTER = 'ch-dev'
        AWS_ECS_TASK_DEFINITION_PATH = './ecs/container-definition-update-image.json'
    }
    tools {
	jdk 'jdk11'
    }
    stages {
        stage('GetCode') { 
            steps {
		//script{
		//     properties([pipelineTriggers([pollSCM('H/1 * * * *')])])
		//  } 
                git branch: 'main', url: 'https://github.com/Prasanna7396/NodeJsApp.git'
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
        stage('SonarQube Analysis'){
             steps {
               withSonarQubeEnv('sonarqube-8.9.2') { 
				sh "mvn sonar:sonar -Dsonar.projectKey=NodeApp"
            }
          }
        }
        stage('Docker Build'){
             steps {
		  withCredentials([string(credentialsId: 'AWS-CREDENTIALS', variable: 'AWS_ECR_URL')]) {
                  echo "Creating the docker image"
		          
				  docker.build("${AWS_ECR_URL}:${POM_VERSION}", " .")
               }
	  }
    }	
}
