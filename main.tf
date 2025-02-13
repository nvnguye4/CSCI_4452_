# Add provider
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "nvnguye4-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "nvnguye4-vpc"
  }
}

# Subnet
resource "aws_subnet" "nvnguye4-subnet" {
  vpc_id                  = aws_vpc.nvnguye4-vpc.id
  cidr_block              = cidrsubnet(aws_vpc.nvnguye4-vpc.cidr_block, 3, 1)
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Security Group

resource "aws_security_group" "nvnguye4-ingress-all" {
  name   = "nvnguye4-ingress-allow-all"
  vpc_id = aws_vpc.nvnguye4-vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Terraform requires egress to be defined as it is disabled by default..
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# EC2 Instance for testing
resource "aws_instance" "nvnguye4-ec2" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  key_name               = var.ami_key_pair
  subnet_id              = aws_subnet.nvnguye4-subnet.id
  vpc_security_group_ids = [aws_security_group.nvnguye4-ingress-all.id]
  tags = {
    Name = "nvnguye4-ec2"
  }
}

# To access the instance, we would need an elastic IP
resource "aws_eip" "nvnguye4-eip" {
  instance = aws_instance.nvnguye4-ec2.id
  vpc      = true
}

# Route traffic from internet to the vpc
resource "aws_internet_gateway" "nvnguye4-igw" {
  vpc_id = aws_vpc.nvnguye4-vpc.id
  tags = {
    Name = "nvnguye4-igw"
  }
}

# Setting up route table
resource "aws_route_table" "nvnguye4-rt" {
  vpc_id = aws_vpc.nvnguye4-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nvnguye4-igw.id
  }

  tags = {
    Name = "nvnguye4-rt"
  }
}

# Associate the route table with the subnet
resource "aws_route_table_association" "nvnguye4-rt-assoc" {
  subnet_id      = aws_subnet.nvnguye4-subnet.id
  route_table_id = aws_route_table.nvnguye4-rt.id
}

# Add a SNS topic
resource "aws_sns_topic" "nvnguye4-sns-topic" {
  name = "nvnguye4-sns-topic"
}
