resource "aws_subnet" "public_subnets" {
  count = length(var.public_subnets_cidr_blocks)
  vpc_id = var.vpc_id
  cidr_block = var.public_subnets_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-subnet-${count.index + 1}"
    Environment = var.env
  }
}

