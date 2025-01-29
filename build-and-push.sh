#!/bin/bash
set -e

# Check if required files exist
if [ ! -f "Dockerfile" ]; then
    echo "Error: Dockerfile not found"
    exit 1
fi

if [ ! -f "Dockerfile.nginx" ]; then
    echo "Error: Dockerfile.nginx not found"
    exit 1
fi

if [ ! -f "nginx/nginx.prod.conf" ]; then
    echo "Error: nginx/nginx.prod.conf not found"
    exit 1
fi

# Get repository details and region from Terraform outputs
cd terraform/1-ecr
AWS_REGION=$(terraform output -raw aws_region)
NODEJS_REPO_URL=$(terraform output -raw nodejs_app_repository_url)
NGINX_REPO_URL=$(terraform output -raw nginx_app_repository_url)

if [ -z "$NODEJS_REPO_URL" ] || [ -z "$NGINX_REPO_URL" ] || [ -z "$AWS_REGION" ]; then
    echo "Error: Could not get repository details from Terraform. Have you run terraform apply?"
    exit 1
fi

# Go back to project root
cd ../..

# Extract account ID from repository URL
ACCOUNT_ID=$(echo $NODEJS_REPO_URL | cut -d. -f1)
IMAGE_TAG=$(git rev-parse --short HEAD)  # Use git commit hash as tag

echo "Building and pushing to ECR repositories in region: $AWS_REGION"

# Set up buildx
docker buildx create --use --name build --node build --driver-opt network=host || true

# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push NodeJS image
echo "Building and pushing NodeJS image..."
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --tag $NODEJS_REPO_URL:$IMAGE_TAG \
    --tag $NODEJS_REPO_URL:latest \
    --file Dockerfile \
    .

# Build and push Nginx image
echo "Building and pushing Nginx image..."
docker buildx build \
    --platform linux/amd64,linux/arm64 \
    --push \
    --tag $NGINX_REPO_URL:$IMAGE_TAG \
    --tag $NGINX_REPO_URL:latest \
    --file Dockerfile.nginx \
    .

# Clean up
docker buildx rm build || true

echo "Successfully built and pushed images:"
echo "NodeJS: $NODEJS_REPO_URL:$IMAGE_TAG"
echo "Nginx: $NGINX_REPO_URL:$IMAGE_TAG"