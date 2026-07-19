provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Enterprise-DevSecOps"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}