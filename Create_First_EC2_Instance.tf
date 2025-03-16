terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
  access_key = "*************************"
  secret_key = "**********************************"
}

resource "aws_instance" "web" {
  ami           = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"

  tags = {
    Name = "Test_Terraform_1"
  }
}

resource "aws_instance" "web1" {
  ami           = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"

  tags = {
    Name = "Test_Terraform_2"
  }
}

resource "aws_instance" "manual_instance" {
  ami = "ami-053b12d3152c0cc71"
  instance_type = "t2.micro"

  tags = {
    Name = "Test_Manual_Instance"
  }
}