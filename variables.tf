variable "aws_region" {
  description = "region of aws"
  type = string
}

variable "env" {
  description = "enviourment type "
  type = string
}

variable "project_name" {
  description = "your project name"
  type = string
}

variable "vpc_cidr_block" {
  description = "cidr block for vpc"
  type = string
}

variable "public_subnets_cidr_blocks" {
  description = "cidr_blocks_for_public_subnets" 
  type = list(string)
  default = []
}

variable "availability_zones" {
    description = "azs where you want to create subnets"
    type = list(string) 
}

variable "instance_type" {
  description = "type of instance"
  type = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "email" {
  description = "email id for sns topic and alarm"
  type = string
}