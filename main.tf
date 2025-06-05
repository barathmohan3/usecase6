provider "aws" {
  region = "eu-west-1"
}

resource "aws_subnet" "subnet_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "subnet-a" }
}

resource "aws_security_group" "allow_http_ssh" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "instance_a" {
  ami                         = ami-03400c3b73b5086e9
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_a.id
  vpc_security_group_ids      = [aws_security_group.allow_http_ssh.id]
  associate_public_ip_address = true

  tags = { Name = "Instance A" }

  user_data =<<-EOF
              #!/bin/bash
              yum install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo '<h1>Home page!</h1><br><h2>(Instance A)</br></h2>' > /usr/share/nginx/html/index.html
              EOF
}

module "iam" {
  source           = "./modules/iam_role"
  lambda_role_name = "ec2-fghj-role"
}

module "start_lambda" {
  source           = "./modules/lambda_function"
  function_name    = "StartEC2Instances"
  handler_file     = "${path.module}/start_lambda.py"
  handler_name     = "start_lambda.lambda_handler"
  role_arn         = module.iam.lambda_role_arn
  environment_vars = {
    INSTANCE_IDS = "i-0169a79a8eb7421ef"
  }
}

module "stop_lambda" {
  source           = "./modules/lambda_function"
  function_name    = "StopEC2Instances"
  handler_file     = "${path.module}/stop_lambda.py"
  handler_name     = "stop_lambda.lambda_handler"
  role_arn         = module.iam.lambda_role_arn
  environment_vars = {
    INSTANCE_IDS = "i-0169a79a8eb7421ef"
  }
}

module "start_schedule" {
  source              = "./modules/cloudwatch_event"
  rule_name           = "StartEC2InstancesRule"
  schedule_expr       = "cron(0 18 ? * MON-FRI *)" 
  lambda_function_arn = module.start_lambda.lambda_role_arn
}

module "stop_schedule" {
  source              = "./modules/cloudwatch_event"
  rule_name           = "StopEC2InstancesRule"
  schedule_expr       =  "cron(0 18 ? * MON-FRI *)" 
  lambda_function_arn = module.stop_lambda.lambda_role_arn
}
