terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
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

  # Add role arn with External Id details for making connection with aws (This is a recommended way, but always make sure to create an External ID alongwith Role for security purpose)
  #   assume_role {
  #     role_arn    = "*****************************" # Role ARN to assume
  #     external_id = "********************"          # External ID
  #   }
}
# Create a security group
resource "aws_security_group" "Test_sg" {
  name_prefix = "example-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }

    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "Test_AMI_Creation_Machine" {
  ami             = "ami-00bb6a80f01f03502" # Replace with a base AMI ID
  instance_type   = "t2.micro"
  key_name        = "Ashutosh-Practice-Key-Pair" # Replace with your key pair
  security_groups = [aws_security_group.Test_sg.name]

  tags = {
    Name = "Test_AMI_Creation_Machine"
  }

  # Wait for the instance to become ready
  provisioner "local-exec" {
    command = "echo 'Instance ${self.id} is ready'"
  }

    provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y apache2",
      "sudo systemctl start apache2",
      "sudo systemctl enable apache2"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("G:/AWS_Work/Ashutosh-Practice-Key-Pair.pem") # Path to your private key
      host        = self.public_ip
    }
  }
}

# Create an AMI from the EC2 instance
resource "aws_ami_from_instance" "Test_AMI" {
  name               = "Test_AMI-${aws_instance.Test_AMI_Creation_Machine.id}"
  source_instance_id = aws_instance.Test_AMI_Creation_Machine.id
  description        = "Test_v8.0.0.36"

  tags = {
    name = "Test_v8.0.0.36"
  }

  # Wait for the AMI creation to complete
  depends_on = [aws_instance.Test_AMI_Creation_Machine]
}

output "instance_id" {
  value = aws_instance.Test_AMI_Creation_Machine.id
}

output "ami_id" {
  value = aws_ami_from_instance.Test_AMI.id
}
