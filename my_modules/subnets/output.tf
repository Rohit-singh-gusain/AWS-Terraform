output "public_subnets_ids" {
    description = "ids of public subnets"
  value = aws_subnet.public_subnets[*].id
}

