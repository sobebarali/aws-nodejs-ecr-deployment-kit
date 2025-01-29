# ECR Infrastructure

This directory contains the Terraform configuration for setting up two Amazon Elastic Container Registry (ECR) repositories to store our Node.js application and Nginx container images.

## Repositories Created

- `uv-nodejs-app-{environment}`: Holds the Node.js application images
- `uv-nodejs-nginx-{environment}`: Holds the Nginx reverse proxy images

## Prerequisites

- AWS CLI configured with the necessary credentials
- Terraform installed (version 1.0+)
- Node.js and npm installed

## Configuration

1. Duplicate the example variables file and modify it as needed:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. Update the variables in `terraform.tfvars`:

```hcl
aws_region = "ap-southeast-4"  # Melbourne region
environment = "dev"            # or "staging", "prod"
allowed_aws_account_arns = [
  "arn:aws:iam::ACCOUNT_ID:root"  # Replace with your AWS account ARN
]
tags = {
  Project     = "uv-nodejs-ecs"
  Environment = "dev"
  Terraform   = "true"
}
```

## Deployment

1. Initialize Terraform:

```bash
terraform init
```

2. Preview the changes:

```bash
terraform plan
```

3. Deploy the configuration:

```bash
terraform validate
terraform apply
```

## Building and Pushing Images

After the ECR repositories are set up, you can build and push images using the script located in the root directory:

```bash
# From the root directory of the project
./build-and-push.sh
```

This script will:

- Retrieve the repository URLs from Terraform outputs
- Build both Node.js and Nginx images using buildx for multi-platform support
- Tag images with both the latest tag and the git commit hash
- Push images to their respective ECR repositories

## Outputs

The following outputs are available:

- `aws_region`: The AWS region where repositories are created
- `nodejs_repository_url`: The URL for the Node.js repository
- `nodejs_repository_name`: The name of the Node.js repository
- `nginx_repository_url`: The URL for the Nginx repository
- `nginx_repository_name`: The name of the Nginx repository

To view the outputs, use:

```bash
terraform output
```

## Cleanup

To remove the ECR repositories:

```bash
terraform destroy
```

**Note**: This action will delete all images in the repositories. Ensure you have backups if necessary.