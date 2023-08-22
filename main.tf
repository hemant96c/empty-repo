resource "aws_subnet" "private_subnet" {
  vpc_id     = data.aws_vpc.vpc.id
  cidr_block = "10.0.9.0/24"

  tags = {
    Name = "My_Private_Subnet"
  }
}



resource "aws_route_table" "my_route_table" {
  vpc_id = data.aws_vpc.vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    nat_gateway_id = data.aws_nat_gateway.nat.id
  }

  tags = {
    Name = "My Route Table"
  }
}



resource "aws_route_table_association" "my_route_table_association" {
  subnet_id = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


resource "aws_security_group" "my_security_group" {
  name_prefix = "My Security Group"
  vpc_id      = data.aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "my_lambda_function" {
  filename         = "lambda.zip"
  function_name    = "lambda"
  role             = data.aws_iam_role.lambda.arn
  handler          = "lambda.lambda_handler"
  runtime          = "python3.7"
  timeout = 63
  vpc_config {
    security_group_ids = [aws_security_group.my_security_group.id]
    subnet_ids         = [aws_subnet.private_subnet.id]
  }

  environment {
    variables = {
      subnet = "${aws_subnet.private_subnet.id}"
    }
  }
}
