output "ec2_ids" {
  value = aws_instance.my_ec2[*].id   
}