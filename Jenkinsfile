pipeline {
    agent any

    environment {
        DOCKERHUB_USERNAME = credentials('dockerhub-username')
        DOCKERHUB_TOKEN    = credentials('dockerhub-token')
        IMAGE_NAME         = 'devops-react-app'
        DEV_REPO           = "${DOCKERHUB_USERNAME}/dev"
        PROD_REPO          = "${DOCKERHUB_USERNAME}/prod"
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

                    if (env.GIT_BRANCH == 'origin/main' || env.GIT_BRANCH == 'main') {
                        env.IMAGE_TAG   = "prod-${shortHash}"
                        env.DOCKER_REPO = env.PROD_REPO
                    } else {
                        env.IMAGE_TAG   = "dev-${shortHash}"
                        env.DOCKER_REPO = env.DEV_REPO
                    }
                    env.FULL_IMAGE = "${env.DOCKER_REPO}:${env.IMAGE_TAG}"
                }
                sh """
                    chmod +x build.sh
                    export DOCKERHUB_USERNAME=${DOCKERHUB_USERNAME}
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
                sh """
                    echo "${DOCKERHUB_TOKEN}" | docker login \
                        -u "${DOCKERHUB_USERNAME}" --password-stdin
                    docker push ${env.FULL_IMAGE}
                    docker push ${env.DOCKER_REPO}:latest
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
    }
}