terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = "ap-south-1"
}

backend "s3" {
    S3 Bucket: "3.devops.candidate.exam"
    Region: "ap-south-1"
    Key: "hemant.choudhary"
  }

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = data.aws_nat_gateway.nat.id
}

resource "aws_subnet" "subnet" {
  vpc_id            = data.aws_vpc.vpc.id
}

resource "aws_iam_role" "lambda" {
  name = "DevOps-Candidate-Lambda-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}