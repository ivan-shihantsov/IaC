
provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc-x-prod" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-x-prod"
  }
}

resource "aws_internet_gateway" "x-prod-IGW" {
  vpc_id = aws_vpc.vpc-x-prod.id

  tags = {
    Name = "x-prod-IGW"
  }
}

# ----------------------------------------

# create 2 public Subnets
resource "aws_subnet" "x-prod-net-pub-A" {
  vpc_id = aws_vpc.vpc-x-prod.id
  cidr_block = "10.0.11.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"

  tags = {
    Name = "x-prod-net-pub-A"
  }
}

resource "aws_subnet" "x-prod-net-pub-B" {
  vpc_id = aws_vpc.vpc-x-prod.id
  cidr_block = "10.0.21.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1b"

  tags = {
    Name = "x-prod-net-pub-B"
  }
}

# add a Route Table for public Subnets + Route to IGW
resource "aws_route_table" "x-prod-RT-pub" {
  vpc_id = aws_vpc.vpc-x-prod.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.x-prod-IGW.id
  }

  tags = {
    Name = "x-prod-RT-pub"
  }
}

# associate the Route Table with public Subnets
resource "aws_route_table_association" "public_assoc_a" {
  subnet_id = aws_subnet.x-prod-net-pub-A.id
  route_table_id = aws_route_table.x-prod-RT-pub.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id = aws_subnet.x-prod-net-pub-B.id
  route_table_id = aws_route_table.x-prod-RT-pub.id
}

# ----------------------------------------

# 2 EIPs & 2 new NAT gateways in public Subnets - for use in private Subnets
resource "aws_eip" "nat_eip_a" {
  domain = "vpc"

  tags = {
    Name = "nat_eip_a"
  }
}

resource "aws_eip" "nat_eip_b" {
  domain = "vpc"

  tags = {
    Name = "nat_eip_b"
  }
}

resource "aws_nat_gateway" "x-prod-NATGW-net-A" {
  connectivity_type = "public"
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id = aws_subnet.x-prod-net-pub-A.id

  tags = {
    Name = "x-prod-NATGW-net-A"
  }
}

resource "aws_nat_gateway" "x-prod-NATGW-net-B" {
  connectivity_type = "public"
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id = aws_subnet.x-prod-net-pub-B.id

  tags = {
    Name = "x-prod-NATGW-net-B"
  }
}

# ----------------------------------------

# create 2 private Subnets
resource "aws_subnet" "x-prod-net-priv-A" {
  vpc_id = aws_vpc.vpc-x-prod.id
  cidr_block = "10.0.12.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-central-1a"

  tags = {
    Name = "x-prod-net-priv-A"
  }
}

resource "aws_subnet" "x-prod-net-priv-B" {
  vpc_id = aws_vpc.vpc-x-prod.id
  cidr_block = "10.0.22.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-central-1b"

  tags = {
    Name = "x-prod-net-priv-B"
  }
}

# add 2 Route Tables for private Subnets + Route to NAT GW
resource "aws_route_table" "x-prod-RT-priv-A" {
  vpc_id = aws_vpc.vpc-x-prod.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.x-prod-NATGW-net-A.id
  }

  tags = {
    Name = "x-prod-RT-priv-A"
  }
}

resource "aws_route_table" "x-prod-RT-priv-B" {
  vpc_id = aws_vpc.vpc-x-prod.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.x-prod-NATGW-net-B.id
  }

  tags = {
    Name = "x-prod-RT-priv-B"
  }
}

# associate Route Tables with private Subnets
resource "aws_route_table_association" "private_assoc_a" {
  subnet_id = aws_subnet.x-prod-net-priv-A.id
  route_table_id = aws_route_table.x-prod-RT-priv-A.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id = aws_subnet.x-prod-net-priv-B.id
  route_table_id = aws_route_table.x-prod-RT-priv-B.id
}

# ----------------------------------------

# create 2 database Subnets
resource "aws_subnet" "x-prod-net-db-A" {
  vpc_id = aws_vpc.vpc-x-prod.id
  cidr_block = "10.0.13.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-central-1a"

  tags = {
    Name = "x-prod-net-db-A"
  }
}

resource "aws_subnet" "x-prod-net-db-B" {
  vpc_id = aws_vpc.vpc-x-prod.id
  cidr_block = "10.0.23.0/24"
  map_public_ip_on_launch = false
  availability_zone = "eu-central-1b"

  tags = {
    Name = "x-prod-net-db-B"
  }
}

# add a Route Table for database Subnet
resource "aws_route_table" "x-prod-RT-db" {
  vpc_id = aws_vpc.vpc-x-prod.id

  tags = {
    Name = "x-prod-RT-db"
  }
}

# associate the Route Table with database Subnets
resource "aws_route_table_association" "database_assoc_a" {
  subnet_id = aws_subnet.x-prod-net-db-A.id
  route_table_id = aws_route_table.x-prod-RT-db.id
}

resource "aws_route_table_association" "database_assoc_b" {
  subnet_id = aws_subnet.x-prod-net-db-B.id
  route_table_id = aws_route_table.x-prod-RT-db.id
}

