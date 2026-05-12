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

                    // Branch-based repo selection
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

                    echo "Docker Repo : ${env.DOCKER_REPO}"
                    echo "Image Tag   : ${env.IMAGE_TAG}"
                    echo "Full Image  : ${env.FULL_IMAGE}"
                }

                sh """
                    docker build \
                        -t ${IMAGE_NAME}:latest \
                        -t ${FULL_IMAGE} \
                        -t ${DOCKER_REPO}:latest \
                        .
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {

                sh """
                    echo "${DOCKERHUB_TOKEN}" | docker login \
                        -u "${DOCKERHUB_USERNAME}" --password-stdin

                    docker push ${FULL_IMAGE}

                    docker push ${DOCKER_REPO}:latest

                    docker logout
                """
            }
        }

        stage('Deploy') {
            steps {

                sh """
                    export DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME}
                    export DOCKERHUB_TOKEN=${DOCKERHUB_TOKEN}

                    chmod +x deploy.sh

                    ./deploy.sh
                """
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

        always {
            cleanWs()
        }
    }
}