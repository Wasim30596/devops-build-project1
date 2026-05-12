#!/bin/bash
set -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ -z "$DOCKERHUB_USERNAME" ]; then
    echo "❌ ERROR: DOCKERHUB_USERNAME not set"
    exit 1
fi

if [ "$BRANCH" = "master" ] || [ "$BRANCH" = "main" ]; then
    DOCKER_REPO="${DOCKERHUB_USERNAME}/prod"
    TAG="prod-$(git rev-parse --short HEAD)"
else
    DOCKER_REPO="${DOCKERHUB_USERNAME}/dev"
    TAG="dev-$(git rev-parse --short HEAD)"
fi

FULL_IMAGE="${DOCKER_REPO}:${TAG}"
LATEST_IMAGE="${DOCKER_REPO}:latest"

echo "🔐 Logging in to Docker Hub..."
echo "$DOCKERHUB_TOKEN" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin

echo "📤 Pushing $FULL_IMAGE..."
docker push "$FULL_IMAGE"
docker push "$LATEST_IMAGE"

echo "🚀 Deploying..."
docker compose down --remove-orphans 2>/dev/null || true
docker compose up -d

echo "✅ Done!"
docker ps

