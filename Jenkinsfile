pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_TOKEN    = credentials('dockerhub-token')

        IMAGE_NAME = 'devops-react-app'

        DEV_REPO  = "${DOCKERHUB_USERNAME}/dev"
        PROD_REPO = "${DOCKERHUB_USERNAME}/prod"
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch: ${env.GIT_BRANCH}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {

                    def shortHash = sh(
                        script: 'git rev-parse --short HEAD',
                        returnStdout: true
                    ).trim()

                    // PROD branch detection
                    if (
                        env.GIT_BRANCH == 'origin/main' ||
                        env.GIT_BRANCH == 'main' ||
                        env.GIT_BRANCH == 'origin/master' ||
                        env.GIT_BRANCH == 'master'
                    ) {

                        env.IMAGE_TAG   = "prod-${shortHash}"
                        env.DOCKER_REPO = env.PROD_REPO

                    } else {

                        env.IMAGE_TAG   = "dev-${shortHash}"
                        env.DOCKER_REPO = env.DEV_REPO
                    }

                    env.FULL_IMAGE = "${env.DOCKER_REPO}:${env.IMAGE_TAG}"

                    echo "Using Docker Repo: ${env.DOCKER_REPO}"
                    echo "Using Image Tag : ${env.IMAGE_TAG}"
                }

                sh """
                    docker build \
                        -t ${IMAGE_NAME}:latest \
                        -t ${env.FULL_IMAGE} \
                        -t ${env.DOCKER_REPO}:latest \
                        .
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {

                withCredentials([
                    string(credentialsId: 'dockerhub-token', variable: 'DOCKER_TOKEN'),
                    string(credentialsId: 'dockerhub-username', variable: 'DOCKER_USER')
                ]) {

                    sh '''
                        echo "$DOCKER_TOKEN" | docker login \
                            -u "$DOCKER_USER" --password-stdin

                        docker push '"${FULL_IMAGE}"'
                        docker push '"${DOCKER_REPO}"':latest

                        docker logout
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {

                withCredentials([
                    string(credentialsId: 'dockerhub-token', variable: 'DOCKER_TOKEN'),
                    string(credentialsId: 'dockerhub-username', variable: 'DOCKER_USER')
                ]) {

                    sh '''
                        export DOCKERHUB_USERNAME=$DOCKER_USER
                        export DOCKERHUB_TOKEN=$DOCKER_TOKEN

                        chmod +x deploy.sh

                        ./deploy.sh
                    '''
                }
            }
        }
    }

    post {

        success {
            echo "✅ Pipeline succeeded!"
        }

        failure {
            echo "❌ Pipeline failed."
        }
    }
}