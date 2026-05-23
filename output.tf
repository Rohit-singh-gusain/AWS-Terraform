output "vpc_id" {
  value = module.my_vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.subnets.public_subnets_ids
}



output "igw_id" {
  value = module.igw.igw_id
}

output "alb_dns" {
  value = module.alb.alb_endpoint
}



