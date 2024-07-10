provider "aws" {
  region  = "us-east-1"
  profile = "default"

  default_tags {
    tags = {
      Org    = var.org
      Region = "us-east-1"
      Cloud  = "aws"
    }
  }
}

terraform {
  required_version = ">=1.9.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.57"
    }
  }
}
