terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "ec2_security_group" {
  name = "secuirity_group_ec2_instacne"
  description = "Its a security group for Ec2 Instance"
  vpc_id = data.aws_vpc.default.id
  
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "Security group for ec2 Instance"
  }
}


resource "aws_instance" "ec2_instance" {
  count = 2
  ami = "ami-01a00762f46d584a1"
  instance_type = "t3.micro"
  
  subnet_id = data.aws_subnets.default.ids [ count.index % length(data.aws_subnets.default.ids) ]

  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
}
