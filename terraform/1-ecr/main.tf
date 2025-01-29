terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Define an ECR repository for the Node.js application
resource "aws_ecr_repository" "nodejs_app" {
  name = "${var.project_name}-nodejs-${var.environment}"

  # Enable image scanning on push for security
  image_scanning_configuration {
    scan_on_push = true
  }

  # Use AES256 encryption for the repository
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Allow force deletion of the repository
  force_delete = true
  tags         = var.tags
}

# Set a repository policy to allow specific AWS accounts to pull images
resource "aws_ecr_repository_policy" "nodejs_app" {
  repository = aws_ecr_repository.nodejs_app.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_aws_account_arns
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# Define a lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "nodejs_app" {
  repository = aws_ecr_repository.nodejs_app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}

# Define an ECR repository for the Nginx application
resource "aws_ecr_repository" "nginx_app" {
  name = "${var.project_name}-nginx-${var.environment}"

  # Enable image scanning on push for security
  image_scanning_configuration {
    scan_on_push = true
  }

  # Use AES256 encryption for the repository
  encryption_configuration {
    encryption_type = "AES256"
  }

  # Allow force deletion of the repository
  force_delete = true
  tags         = var.tags
}

# Set a repository policy to allow specific AWS accounts to pull images
resource "aws_ecr_repository_policy" "nginx_app" {
  repository = aws_ecr_repository.nginx_app.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = var.allowed_aws_account_arns
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# Define a lifecycle policy to manage image retention
resource "aws_ecr_lifecycle_policy" "nginx_app" {
  repository = aws_ecr_repository.nginx_app.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })
}