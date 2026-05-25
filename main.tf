module "my_vpc" {

    source = "./my_modules/vpc"
    vpc_cidr = var.vpc_cidr_block
    env  = var.env
  
}

module "subnets" {

    source = "./my_modules/subnets"
    vpc_id = module.my_vpc.vpc_id
    public_subnets_cidr_blocks = var.public_subnets_cidr_blocks
    availability_zones = var.availability_zones
    env = var.env
  
}

module "igw" {
  source = "./my_modules/igw"
  vpc_id = module.my_vpc.vpc_id
  env = var.env

}
module "route_tables" {
    source = "./my_modules/routes_tables"
    vpc_id = module.my_vpc.vpc_id
    public_subnet_ids = module.subnets.public_subnets_ids
    igw_id = module.igw.igw_id
    env = var.env
  
}

module "security_groups" {
  source = "./my_modules/security_groups"
  vpc_id = module.my_vpc.vpc_id

}


module "alb" {
  source          = "./my_modules/ALB"
  vpc_id          = module.my_vpc.vpc_id
  subnet_ids      = module.subnets.public_subnets_ids
  security_group_ids = [module.security_groups.sg_for_alb] 
}



module "iam_roles" {
  source = "./my_modules/IAM_ROLES"
  env    = var.env
}

module "ec2_instance" {
  source               = "./my_modules/EC2"
  security_group_ec2   = [module.security_groups.sg_for_ec2]
  instance_type        = var.instance_type
  public_subnets_ids   = module.subnets.public_subnets_ids
  iam_instance_profile = module.iam_roles.instance_profile_name  
  key_name             = var.key_name
}


resource "aws_lb_target_group_attachment" "main" {
  count            = length(module.ec2_instance.ec2_ids)    
  target_group_arn = module.alb.target_group_arn
  target_id        = module.ec2_instance.ec2_ids[count.index]
  port             = 80
}

module "cloud_watch_conf" {
  source = "./my_modules/CLOUD_WATCH"
  ec2_ids =  module.ec2_instance.ec2_ids
  env = var.env
  EMAIL = var.email
}
