provider "aws" {
  region = "us-west-1" 
}

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "key"
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.key.private_key_pem}' > ${path.module}/key.pem && chmod 0700 ${path.module}/key.pem"
  }
}

resource "aws_instance" "vm1" {
  ami           = "ami-0d53d72369335a9d6" 
  instance_type = "t2.micro"
  key_name = aws_key_pair.key_pair.key_name

  tags = {
    Name = "VM1"
  }

  security_groups = ["allow_ssh_http"]
}

resource "aws_instance" "vm2" {
  ami           = "ami-0d53d72369335a9d6" 
  instance_type = "t2.micro"
  key_name = aws_key_pair.key_pair.key_name

  tags = {
    Name = "VM2"
  }

  security_groups = ["allow_ssh_http"]
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP access"

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
    from_port   = 8080
    to_port     = 8080
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

