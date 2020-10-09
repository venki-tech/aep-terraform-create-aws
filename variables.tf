variable "region" {
  default = "eu-west-2"
}

variable "aws_key" {
  default = "_replacekey_"
}

variable "aws_pub_key" {
  default = "_replacekey_.pub"
}

variable "Ubuntu_AMIS" {
  type = map
  default = {
    eu-west-2 = "ami-0fb673bc6ff8fc282"
  }
}

variable "RH_AMIS" {
  type = map
  default = {
    eu-west-2 = "ami-0fc841be1f929d7d1"
  }
}

variable "aws_hostnames" {
  type = map
  default = {
    awswebhost = "web_host"
    awsapphost = "app_host"
    awsdbhost = "db_host"
  }
}
