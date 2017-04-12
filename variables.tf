variable "region" {
  default = "eu-west-1"
}

variable "availability_zone" {
  type = "map"

  default = {
    primary   = "eu-west-1a"
    secondary = "eu-west-1b"
  }
}

variable "autoscaling_group_size" {
  default = {
    min = 5
    max = 5
  }
}

variable "amazon_amis" {
  type = "map"

  default = {
    #ecs optimized
    eu-west-1 = "ami-03238b70"
  }
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_cidr_block1" {
  default = "10.0.1.0/24"
}

variable "public_cidr_block2" {
  default = "10.0.2.0/24"
}
