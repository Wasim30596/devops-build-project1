#!/bin/bash

echo "🔐 Logging in to Docker Hub..."

echo "$DOCKERHUB_TOKEN" | docker login \
-u "$DOCKERHUB_USERNAME" --password-stdin

echo "🛑 Stopping old containers..."
docker compose down || true

echo "🧹 Removing old react-app container if exists..."
docker rm -f react-app || true

echo "📥 Pulling latest image..."
docker compose pull

echo "🚀 Deploying..."
docker compose up -d

echo "✅ Deployment completed!"