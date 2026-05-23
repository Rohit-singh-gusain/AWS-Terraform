variable "vpc_id" {
  description = "vpc where you want to create route tables"
  type = string
}

variable "public_subnet_ids" {
  description = "public_subnets where you want to create route table"
  type = list(string)

}



variable "igw_id" {
  description = "internet gateway id "
  type = string
}
variable "env" {
  type = string
}

