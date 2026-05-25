variable "env" {
  type = string
  
}

variable "ec2_ids" {
    description = "ec2_ids for monitoring ec2 CPU USAGE"
    type = list(string)
  
}

variable "EMAIL" {
  description = "email for SNS and ALARM"
  type = string
}