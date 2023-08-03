terraform {
  backend "s3" {
    bucket = "staff-manager-tfstates"
    workspace_key_prefix = "int"
    key = "int-staff-manager.tfstate"
    region = "us-east-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}