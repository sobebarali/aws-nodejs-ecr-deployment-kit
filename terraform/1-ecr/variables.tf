variable "aws_region" {
  type        = string
  description = "AWS region to deploy to"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "The AWS region must be a valid region code, e.g., us-east-1."
  }
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "nodejs-aws-ecr"
}

variable "environment" {
  type        = string
  description = "Environment (dev/staging/prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of 'dev', 'staging', or 'prod'."
  }
}

variable "allowed_aws_account_arns" {
  type        = list(string)
  description = "List of AWS account ARNs allowed to pull images"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}