terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "custom_vpc" {
  tags = {

    name = "custom_vpc"
  }
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "custom_subnet" {
  count      = 2
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = cidrsubnet(aws_vpc.custom_vpc.cidr_block, 8, count.index)
}

resource "aws_security_group" "ec2_security_group" {
  name        = "ec2_security_group"
  description = "description of this group"
  vpc_id      = aws_vpc.custom_vpc.id


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

  tags = {
    name = " "
  }
}

resource "aws_instance" "ec2_instance" {
  count         = 2
  ami           = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.custom_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
}

