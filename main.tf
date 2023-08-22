terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"

}


# Create routing table
resource "aws_route_table" "my_route_table" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = data.aws_nat_gateway.nat.id
  }

  tags = {
    Name = "My Route Table"
  }
}

# # Create routing table
# resource "aws_route_table" "my_route_table1" {
#   vpc_id = data.aws_vpc.vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = data.aws_nat_gateway.nat.id
#   }

#   tags = {
#     Name = "My Route Table"
#   }
# }

# Associate subnet with the routing table
resource "aws_route_table_association" "my_route_table_association" {
  subnet_id = data.aws_subnet.subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

# # Create a route in the private route table for internet-bound traffic
# resource "aws_route" "private_route" {
#   route_table_id         = aws_route_table.my_route_table1.id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = data.aws_nat_gateway.nat.id
# }

# Create security group
resource "aws_security_group" "my_security_group" {
  name_prefix = "My Security Group"
  vpc_id      = data.aws_vpc.vpc.id

  # ingress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  # }

  ingress {
    from_port   = 0
    to_port     = 0
    self      = true
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# Create Lambda function
resource "aws_lambda_function" "my_lambda_function" {
  filename         = "lambda.zip"
  function_name    = "lambda"
  role             = data.aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.7"
  timeout = 63
  vpc_config {
    security_group_ids = [aws_security_group.my_security_group.id]
    subnet_ids         = [data.aws_subnet.subnet.id]
  }

  environment {
    variables = {
      subnet = "${data.aws_subnet.subnet.id}"
    }
  }
}

resource "aws_iam_policy" "lambda-policy" {
  name = "lambda-ec2-stop-start"

  policy = jsonencode(
    {
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LambdaVPCAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:AssignPrivateIpAddresses",
        "ec2:UnassignPrivateIpAddresses",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs",
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}


  )
}

resource "aws_iam_role_policy_attachment" "lambda-ec2-policy-attach" {
  policy_arn = aws_iam_policy.lambda-policy.arn
  role = data.aws_iam_role.lambda.name
}
