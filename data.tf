data "aws_nat_gateway" "nat" {
  id = "nat-0d688bbff8a47b274"
}

data "aws_vpc" "vpc" {
  id = "vpc-00bf0d10a6a41600c"
}

data "aws_iam_role" "lambda" {
  name = "DevOps-Candidate-Lambda-Role"
}
