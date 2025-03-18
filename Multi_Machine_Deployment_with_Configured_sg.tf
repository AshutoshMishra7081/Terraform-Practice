terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

provider "aws" {
  region = "ap-south-1" # Change as needed

  # Add access key and secret access key access the aws to create the instance {But this is not recomended way to connect to aws}
  access_key = "*************************"
  secret_key = "**********************************"

#   assume_role {
  #     role_arn    = "*****************************" # Role ARN to assume
  #     external_id = "********************"          # External ID
#   }
}

# Security Group for SSH
resource "aws_security_group" "ssh_sg" {
  name        = "ssh_sg"
  description = "Allow SSH access from my IP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"] # Replace YOUR_IP_ADDRESS with your IP
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"] # Replace YOUR_IP_ADDRESS with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for HTTP (Web)
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP access from backend instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [] # Will add backend private IP dynamically
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for HTTP (Backend)
resource "aws_security_group" "backend_sg" {
  name        = "backend_sg"
  description = "Allow HTTP access from web instance"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [] # Will add web private IP dynamically
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Web Instance
resource "aws_instance" "web_instance" {
  ami           = "ami-00bb6a80f01f03502" # Replace with the desired Ubuntu AMI
  instance_type = "t2.micro"
  key_name        = "Ashutosh-Practice-Key-Pair" # Attach the key pair

  security_groups = [
    aws_security_group.ssh_sg.name,
    aws_security_group.web_sg.name
  ]

  tags = {
    Name = "vpc_WebInstance_v8.0"
  }

#   provisioner "file" {
#     source      = "./docker-compose.yml/"
#     destination = "/home/ubuntu"

#     connection {
#       type     = "ssh"
#       user     = "ubuntu"
#       private_key = "${file("~/.ssh/id_rsa")}" # Path to your private key
#       host     = self.public_ip
#     }
#   }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("G:/AWS_Work/Ashutosh-Practice-Key-Pair.pem")}" # Path to your private key
      host     = self.public_ip
    }
  }
}

# Backend Instance
resource "aws_instance" "backend_instance" {
  ami           = "ami-00bb6a80f01f03502" # Replace with the desired Ubuntu AMI
  instance_type = "t2.micro"
  key_name        = "Ashutosh-Practice-Key-Pair" # Attach the key pair

  security_groups = [
    aws_security_group.ssh_sg.name,
    aws_security_group.backend_sg.name
  ]

  tags = {
    Name = "vpc_BackendInstance_v8.0"
  }

#   provisioner "file" {
#     source      = "./docker-compose_Backend.yml/"
#     destination = "/home/ubuntu"

#     connection {
#       type     = "ssh"
#       user     = "ubuntu"
#       private_key = "${file("~/.ssh/id_rsa")}" # Path to your private key
#       host     = self.public_ip
#     }
#   }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]

    connection {
      type     = "ssh"
      user     = "ubuntu"
      private_key = "${file("G:/AWS_Work/Ashutosh-Practice-Key-Pair.pem")}" # Path to your private key
      host     = self.public_ip
    }
  }
}

# Add dynamic rules for HTTP whitelisting
resource "aws_security_group_rule" "web_to_backend" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.web_sg.id
  cidr_blocks = ["${aws_instance.backend_instance.private_ip}/32"]
}

resource "aws_security_group_rule" "backend_to_web" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  security_group_id = aws_security_group.backend_sg.id
  cidr_blocks = ["${aws_instance.web_instance.private_ip}/32"]
}
