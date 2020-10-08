variable "region" {
  default = "eu-west-2"
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
