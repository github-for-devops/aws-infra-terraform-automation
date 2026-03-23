resource "aws_vpc" "application_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.application_vpc.id
}

resource "aws_subnet" "public_subnets" {
  count = 2
  vpc_id = aws_vpc.application_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnets" {
  count = 2
  vpc_id = aws_vpc.application_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = var.azs[count.index]
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
}

resource "aws_route_table" "public_sub_rt" {
  vpc_id = aws_vpc.application_vpc.id
}

resource "aws_route" "pub_sub_rt" {
  route_table_id = aws_route_table.public_sub_rt.id
  gateway_id     = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "pub_sub_rt_association" {
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_sub_rt.id
}

resource "aws_route_table" "private_sub_rt" {
  vpc_id = aws_vpc.application_vpc.id
}

resource "aws_route" "priv_sub_rt" {
  route_table_id = aws_route_table.private_sub_rt.id
  nat_gateway_id = aws_nat_gateway.nat.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "priv_sub_rt_association" {
  count = 2
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_sub_rt.id
}