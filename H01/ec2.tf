terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.37.0"
    }
  }
}

#confinure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.accesskey
  secret_key = var.secretkey
}

#make security group
resource "aws_security_group" "allow_http_https_ssh" {
  name = "allow_http_https_ssh"
  description = "Allow http/https traffic and ssh from static ip"

  ingress {
    description = "Allow all HTTP traffic"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allo all HTTPS traffic"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH traffic from static IP"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["194.110.84.121/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

}

resource "aws_instance" "myec2" {
  ami = "ami-09e67e426f25ce0d7"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.allow_http_https_ssh.name]
  key_name = "aws-key"
}

resource "local_file" "inventory" {
  content = templatefile("inventory.template",
    {
      public_ip = aws_instance.myec2.public_ip
    }
  )
  filename = "inventory"
}

resource "time_sleep" "wait" {
  depends_on = [aws_instance.myec2]
  create_duration = "150s"
}

resource "null_resource" "run_ansible"{
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory playbook.yml"
  }
  depends_on = [time_sleep.wait]
}

output "instance_ip"{
  value = aws_instance.myec2.public_ip
}
