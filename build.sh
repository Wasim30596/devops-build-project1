#!/bin/bash
set -e

IMAGE_NAME="devops-react-app"
BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
    DOCKER_REPO="${DOCKERHUB_USERNAME}/prod"
    TAG="prod-$(git rev-parse --short HEAD)"
else
    DOCKER_REPO="${DOCKERHUB_USERNAME}/dev"
    TAG="dev-$(git rev-parse --short HEAD)"
fi

FULL_IMAGE="${DOCKER_REPO}:${TAG}"
LATEST_IMAGE="${DOCKER_REPO}:latest"

echo "Building image: $FULL_IMAGE"
docker build -t "$IMAGE_NAME:latest" -t "$FULL_IMAGE" -t "$LATEST_IMAGE" .
echo "✅ Build successful!"