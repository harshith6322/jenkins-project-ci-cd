pipeline {
    agent {
        label 'slave_1-nodejs'
    }

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials') // Ensure this matches your Jenkins credentials ID
        IMAGE_NAME = 'harshithreddy6322/reactapp'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('Checkout Repository') {
            steps {
                // Using 'checkout scm' assumes the pipeline is triggered by a multibranch pipeline or a GitHub hook
                checkout scm
                // Alternatively, specify the repository URL and branch explicitly:
                // git url: 'https://github.com/harshith6322/jenkins-project-ci-cd.git', branch: 'main'
            }
        }

        stage('Setup Node.js') {
            steps {
            script {
                // Check if Node.js is installed
                def nodeInstalled = sh(script: 'which node || true', returnStdout: true).trim()
                if (!nodeInstalled) {
                // Install Node.js using NVM
                sh '''
                    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
                    export NVM_DIR="$HOME/.nvm"
                    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
                    nvm install 21
                    nvm use 21
                '''
                }
            }
            }
        }

        stage('Install Dependencies') {
            steps {
            sh 'npm install'
            }
        }

        stage('Lint') {
            steps {
                sh 'npm run lint'
            }
        }

        stage('Test') {
            steps {
                // Using 'set -o pipefail' ensures that the pipeline fails if tests fail, even when piped
                sh 'set -o pipefail; npm run test | tee test-results.log'
            }
            post {
                always {
                    // Archive test results for later inspection
                    archiveArtifacts artifacts: 'test-results.log', allowEmptyArchive: true
                }
            }
        }

        stage('Build Application') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                    // Tag the image as 'latest' for convenience
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest"
                }
            }
        }

        stage('Test Docker Image') {
            steps {
                script {
                    // Run the Docker container in detached mode
                    sh 'docker-compose up -d'
                    // Optionally, add health checks or test commands here
                }
            }
            post {
                always {
                    // Ensure the container is stopped and removed after testing
                    sh 'docker-compose down'
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                script {
                    // Log in to Docker Hub using credentials stored in Jenkins
                    withDockerRegistry([credentialsId: 'docker-hub-credentials']) {
                        // Push both the versioned and latest tags
                        sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            // Clean up the workspace to maintain a clean build environment
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Build failed!'
            // Optionally, send notifications or alerts here
        }
    }
}
