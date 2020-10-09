provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_key_pair" "example" {
  key_name   = var.aws_key
  public_key = file(var.aws_pub_key)
}

resource "aws_instance" "appserver" {
  key_name      = aws_key_pair.example.key_name
  ami           = lookup(var.Ubuntu_AMIS,var.region)
  instance_type = "t2.micro"
  tags          = {
    Name        = lookup(var.aws_hostnames,var.awsapphost)
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(aws_key_pair.example.key_name)
    host        = self.public_ip
  }

  provisioner "local-exec" {
  command = "echo connect to appserver using: ssh -i aws_key_pair.example.key_name ubuntu@${aws_instance.appserver.public_ip}"
  }
}

resource "aws_instance" "dbserver" {
  key_name      = aws_key_pair.example.key_name
  ami           = lookup(var.Ubuntu_AMIS,var.region)
  instance_type = "t2.micro"
  tags          = {
    Name        = lookup(var.aws_hostnames,var.awsdbhost)
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(aws_key_pair.example.key_name)
    host        = self.public_ip
  }

  provisioner "local-exec" {
    command = "echo connect to dbserver using: ssh -i aws_key_pair.example.key_name ubuntu@${aws_instance.dbserver.public_ip}"
  }
}

  resource "aws_instance" "webserver" {
    key_name      = aws_key_pair.example.key_name
    ami           = lookup(var.RH_AMIS,var.region)
    instance_type = "t2.micro"
    tags          = {
    Name        = lookup(var.aws_hostnames,var.awswebhost)
    }

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(aws_key_pair.example.key_name)
      host        = self.public_ip
    }

    provisioner "local-exec" {
      command = "echo connect to webserver using: ssh -i aws_key_pair.example.key_name ec2-user@${aws_instance.webserver.public_ip}"
    }
}

resource "null_resource" "for_ansible" {
  provisioner "local-exec" {
    command = "echo 'aws_appserver ansible_host=${aws_instance.appserver.public_ip} ansible_connection=ssh ansible_user=ubuntu ansible_ssh_private_key_file=aws_key_pair.example.key_name'"
  }

  provisioner "local-exec" {
    command = "echo 'aws_dbserver ansible_host=${aws_instance.dbserver.public_ip} ansible_connection=ssh ansible_user=ubuntu ansible_ssh_private_key_file=aws_key_pair.example.key_name'"
  }

  provisioner "local-exec" {
    command = "echo 'aws_webserver ansible_host=${aws_instance.webserver.public_ip} ansible_connection=ssh ansible_user=ec2-user  ansible_ssh_private_key_file=aws_key_pair.example.key_name'"
  }
}
