provider "aws" {
  region     = "us-east-1"
  access_key = "XXXXXXXXXXXXXXXX"
  secret_key = "YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY"
}

## Create VPC ##
resource "aws_vpc" "terraform-vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "XXXXXXXXXXXXXXXXXXX"
  }
}

output "aws_vpc_id" {
  value = aws_vpc.terraform-vpc.id
}

## Security Group for EC2 ##
resource "aws_security_group" "terraform_private_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id      = aws_vpc.terraform-vpc.id
  name        = "terraform_ec2_private_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "ec2-private-sg"
  }
}

output "aws_security_gr_id" {
  value = aws_security_group.terraform_private_sg.id
}

## Subnet 1 ##
resource "aws_subnet" "terraform-subnet_1" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "terraform-subnet_1"
  }
}

## Subnet 2 ##
resource "aws_subnet" "terraform-subnet_2" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "172.16.20.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "terraform-subnet_2"
  }
}

output "aws_subnet_subnet_1" {
  value = aws_subnet.terraform-subnet_1.id
}

## EC2 Instances ##
resource "aws_instance" "terraform_wapp" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.terraform_private_sg.id]
  subnet_id                   = aws_subnet.terraform-subnet_1.id
  key_name                    = "ashis-8byte"
  associate_public_ip_address = true
  tags = {
    Name        = "8BYTE.AI"
    Environment = "development"
    Project     = "8BYTE.AI"
  }
}

resource "aws_instance" "terraform_wapp_2" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.terraform_private_sg.id]
  subnet_id                   = aws_subnet.terraform-subnet_1.id
  key_name                    = "ashis-8byte"
  associate_public_ip_address = true
  tags = {
    Name        = "8BYTE.AI2"
    Environment = "development"
    Project     = "8BYTE.AI"
  }
}

output "instance_id_list" {
  value = [aws_instance.terraform_wapp.id, aws_instance.terraform_wapp_2.id]
}

## Internet Gateway ##
resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = {
    Name = "terraform-demo-igw"
  }
}

## Route Table ##
resource "aws_route_table" "terraform_public_rt" {
  vpc_id = aws_vpc.terraform-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }
  tags = {
    Name = "terraform-public-rt"
  }
}

## Associate Route Table ##
resource "aws_route_table_association" "terraform_subnet_assoc_1" {
  subnet_id      = aws_subnet.terraform-subnet_1.id
  route_table_id = aws_route_table.terraform_public_rt.id
}

resource "aws_route_table_association" "terraform_subnet_assoc_2" {
  subnet_id      = aws_subnet.terraform-subnet_2.id
  route_table_id = aws_route_table.terraform_public_rt.id
}

## ALB Security Group ##
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP access to ALB"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

## Target Group ##
resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terraform-vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

## Attach EC2s to Target Group ##
resource "aws_lb_target_group_attachment" "wapp1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.terraform_wapp.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "wapp2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.terraform_wapp_2.id
  port             = 80
}

## Application Load Balancer ##
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.terraform-subnet_1.id,
    aws_subnet.terraform-subnet_2.id
  ]
  tags = {
    Name = "app-alb"
  }
}

## ALB Listener ##
resource "aws_lb_listener" "app_alb_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}
