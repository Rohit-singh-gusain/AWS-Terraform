output "sg_for_ec2" {
  value = aws_security_group.ec2_sg.id    
}

output "sg_for_alb" {
  value = aws_security_group.alb_sg.id    
}