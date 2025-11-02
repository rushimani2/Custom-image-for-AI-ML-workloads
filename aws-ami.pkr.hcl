packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_access_key" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

source "amazon-ebs" "basic" {
  region                  = "ap-south-1" # Mumbai
  access_key              = var.aws_access_key
  secret_key              = var.aws_secret_key
  instance_type           = "t2.micro"
  ami_name                = "my-simple-ami-{{timestamp}}"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  ssh_username = "ec2-user"
}

build {
  name    = "simple-ami-build"
  sources = ["source.amazon-ebs.basic"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "echo 'Hello from my custom AMI' | sudo tee /etc/motd"
    ]
  }
}
