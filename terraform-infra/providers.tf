terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.69.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Region comes from the AWS profile / environment.


provider "aws" {
  alias  = "s3"
  region = var.s3_region
}

provider "aws" {
  alias  = "ec2"
  region = var.ec2_region
}
