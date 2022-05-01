provider "aws" {
  region = var.AWS_REGION
}

data "aws_region" "current" {
}

provider "http" {
}
