// Outputs for AWS Region
output "aws_region" {
  value       = var.aws_region
  description = "The AWS region where resources are deployed"
}

// Outputs for Node.js Application ECR Repository
output "nodejs_app_repository_url" {
  description = "The URL of the Node.js ECR repository"
  value       = aws_ecr_repository.nodejs_app.repository_url
}

output "nodejs_app_repository_name" {
  description = "The name of the Node.js ECR repository"
  value       = aws_ecr_repository.nodejs_app.name
}

// Outputs for Nginx Application ECR Repository
output "nginx_app_repository_url" {
  description = "The URL of the Nginx ECR repository"
  value       = aws_ecr_repository.nginx_app.repository_url
}

output "nginx_app_repository_name" {
  description = "The name of the Nginx ECR repository"
  value       = aws_ecr_repository.nginx_app.name
}
