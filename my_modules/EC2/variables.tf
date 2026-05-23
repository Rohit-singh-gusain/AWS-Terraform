variable "public_subnets_ids" {
  description = "public subnet ids"
  type = list(string)
}

variable "instance_type" {
    description = "type of instance"
    type = string
  
}

variable "security_group_ec2" {
  description = "sg for ec2"
  type = list(string)
}


variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}