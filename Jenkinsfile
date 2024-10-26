pipeline {
    agent any 
    tools {
        jdk 'jdk'

    }
    environment  {
        SCANNER_HOME = tool 'sonar-scanner'
        GCP_DEFAULT_REGION = 'europe-west1'
        IMAGE_NAME = 'frontend'
        GCP_GCR_REPO_NAME = 'frontend-repo'
        PROJECT_ID = credentials('PROJECT_ID')
        GCR_URL = "${GCP_DEFAULT_REGION}-docker.pkg.dev/${PROJECT_ID}/${GCP_GCR_REPO_NAME}/${IMAGE_NAME}"
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
                        -Dsonar.projectName=frontend \
                        -Dsonar.projectKey=frontend 
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
                    dir('Application-Code/app') {
                        docker.build("${GCR_URL}:${BUILD_NUMBER}")
                    }
                }
            }
        }
        stage('Push to GCR') {
            steps {
                script {
                    docker.withRegistry("https://${GCP_DEFAULT_REGION}-docker.pkg.dev", 'gcr') {
                        docker.image("${GCR_URL}:${BUILD_NUMBER}").push()
                    }
                }
            }
        }
        stage('Trivy Image Scan') {
            steps {
                script {
                    sh ' trivy image ${GCR_URL}:${BUILD_NUMBER} > trivyimage.txt'
                }
            }
        }
        /*stage('Checkout from Git to edit') {
            steps {
                git credentialsId: 'GITHUB', url: "${GIT_REPO_URL}", branch: 'main'
            }
        }*/
        /*stage('Update Deployment file') {
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
        }*/
    }
}