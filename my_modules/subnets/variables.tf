variable "public_subnets_cidr_blocks" {
  description = "cidr_blocks_for_public_subnets" 
  type = list(string)
  default = []
}


variable "vpc_id" {
  description = "vpc id where subnets will going to be create"
  type = string
  
}

variable "availability_zones" {
    description = "azs where you want to create subnets"
    type = list(string) 
}

variable "env" {
    type = string
  
}