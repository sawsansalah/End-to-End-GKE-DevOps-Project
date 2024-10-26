pipeline {
    agent any 
    tools {
        jdk 'jdk'
    }
    environment  {
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_NAME = 'frontend'
        DOCKER_HUB_REPO = '3788/frontend' 
        DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
        GIT_REPO_URL = "https://github.com/sawsansalah/End-to-End-GKE-DevOps-Project.git"
        
    }
    stages {
        stage('Cleaning Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git credentialsId: 'GITHUB', url: "${GIT_REPO_URL}", branch: 'main'
            }
        }
        stage('Sonarqube Analysis') {
            steps {
                dir('Application-Code/app') {
                    withSonarQubeEnv('sonar-server') {
                        sh ''' 
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=${IMAGE_NAME} \
                        -Dsonar.projectKey=${IMAGE_NAME} 
                        '''
                    }
                }
            }
        }
        stage('Quality Check') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            }
        }

        stage('Trivy File Scan') {
            steps {
                dir('Application-Code/app') {
                    sh 'trivy fs . > trivyfs.txt'
                }
            }
        }
        stage('Docker Image Build') {
            steps {
                script {
                    dir('Application-Code') {
                        docker.build("${DOCKER_HUB_REPO}:${BUILD_NUMBER}")
                    }
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_HUB_CREDENTIALS}") {
                        docker.image("${DOCKER_HUB_REPO}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }
        stage('Trivy Image Scan') {
            steps {
                script {
                    sh 'trivy image ${DOCKER_HUB_REPO}:${BUILD_NUMBER} > trivyimage.txt'
                }
            }
        }
        stage('Checkout from Git to edit') {
            steps {
                git credentialsId: 'GITHUB', url: "${GIT_REPO_URL}", branch: 'main'
            }
        }
        stage('Update Deployment file') {
            environment {
                GIT_REPO_NAME = "End-to-End-GKE-DevOps-Project.git"
                GIT_USER_NAME = "sawsansalah"
            }
            steps {
                dir('Kubernetes-Manifests-file/frontend') {
                    withCredentials([string(credentialsId: 'github', variable: 'GITHUB_TOKEN')]) {
                        sh '''
                            ls
                            git config user.email "sawsan.salaheldin@gmail.com"
                            git config user.name "sawsansalah"
                            BUILD_NUMBER=${BUILD_NUMBER}
                            echo $BUILD_NUMBER
                            imageTag=$(grep -oP '(?<=frontend:)[^ ]+' deployment.yaml)
                            echo $imageTag
                            sed -i "s/${IMAGE_NAME}:${imageTag}/${IMAGE_NAME}:${BUILD_NUMBER}/" deployment.yaml
                            git add deployment.yaml
                            git commit -m "Update deployment Image to version ${BUILD_NUMBER}"
                            git push https://${GITHUB_TOKEN}@github.com/${GIT_USER_NAME}/${GIT_REPO_NAME} HEAD:main
                        '''
                    }
                }
            }
        }
    }
}