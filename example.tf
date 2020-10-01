provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_key_pair" "example" {
  key_name   = "vvkey"
  public_key = file("vvkey.pub")
}

resource "aws_instance" "u1" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-0fb673bc6ff8fc282"
  instance_type = "t2.micro"
  tags          = {
    Name        = "ubuntu-java"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("vvkey")
    host        = self.public_ip
  }

  provisioner "local-exec" {
  command = "echo connect to u1 using: ssh -i vvkey ubuntu@${aws_instance.u1.public_ip}"
  }
}

resource "aws_instance" "u2" {
  key_name      = aws_key_pair.example.key_name
  ami           = "ami-0fb673bc6ff8fc282"
  instance_type = "t2.micro"
  tags          = {
    Name        = "ubuntu-mysql"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("vvkey")
    host        = self.public_ip
  }

  provisioner "local-exec" {
    command = "echo connect to u2 using: ssh -i vvkey ubuntu@${aws_instance.u2.public_ip}"
  }
}

  resource "aws_instance" "rhel1" {
    key_name      = aws_key_pair.example.key_name
    ami           = "ami-0fc841be1f929d7d1"
    instance_type = "t2.micro"
    tags          = {
      Name        = "rhel-apache"
    }

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("vvkey")
      host        = self.public_ip
    }

    provisioner "local-exec" {
      command = "echo connect to rhel1 using: ssh -i vvkey ec2-user@${aws_instance.rhel1.public_ip}"
    }
}

resource "null_resource" "for_ansible" {
  provisioner "local-exec" {
    command = "echo 'aws_u1 ansible_host=${aws_instance.u1.public_ip} ansible_connection=ssh ansible_user=ubuntu ansible_ssh_private_key_file=vvkey'"
  }

  provisioner "local-exec" {
    command = "echo 'aws_u2 ansible_host=${aws_instance.u2.public_ip} ansible_connection=ssh ansible_user=ubuntu ansible_ssh_private_key_file=vvkey'"
  }

  provisioner "local-exec" {
    command = "echo 'aws_rhel1 ansible_host=${aws_instance.rhel1.public_ip} ansible_connection=ssh ansible_user=ec2-user  ansible_ssh_private_key_file=vvkey'"
  }
}
