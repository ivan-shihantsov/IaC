
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

# ----------------------------------------

# create Security Group for Bastion host & allow SSH and ICMP traffic
resource "aws_security_group" "x-prod-bastion-ssh-SG" {
  name = "x-prod-bastion-ssh-SG"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id = aws_vpc.vpc-x-prod.id

  ingress {
    description = "Allow all ICMP"
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow all SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "x-prod-bastion-ssh-SG"
  }
}

# key pair for Bastion
resource "aws_key_pair" "x-prod-bastion-key" {
  key_name = "x-prod-bastion-key"
  public_key = file("~/.ssh/my-key.pub")
}

# Launch Template - based on Amazon Linux 2023 kernel-6.1 AMI
resource "aws_launch_template" "x-prod-bastion-LC" {
  name = "x-prod-bastion-LC"
  image_id = "ami-0a72753edf3e631b7"
  instance_type = "t2.micro"
  key_name = aws_key_pair.x-prod-bastion-key.key_name

  network_interfaces {
    security_groups = [aws_security_group.x-prod-bastion-ssh-SG.id]
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "x-prod-bastion"
    }
  }
}

# ASG with 1 instance of Bastion
resource "aws_autoscaling_group" "x-prod-bastion-ASG" {
  name = "x-prod-bastion-ASG"
  vpc_zone_identifier = [aws_subnet.x-prod-net-pub-A.id, aws_subnet.x-prod-net-pub-B.id]
  desired_capacity = 1
  max_size = 1
  min_size = 1

  launch_template {
    id = aws_launch_template.x-prod-bastion-LC.id
    version = "$Latest"
  }
}

# ----------------------------------------

# create test EC2 instance in private-a Subnet (App Tier)
resource "aws_instance" "EC2-priv-A" {
  ami = "ami-0a72753edf3e631b7"
  instance_type = "t2.micro"
  key_name = "x-prod-bastion-key"
  vpc_security_group_ids = [aws_security_group.x-prod-bastion-ssh-SG.id]
  subnet_id = aws_subnet.x-prod-net-priv-A.id

  tags = {
    Name = "EC2-priv-A"
  }
}

# create test EC2 instance in db-b Subnet (DB Tier)
resource "aws_instance" "EC2-db-B" {
  ami = "ami-0a72753edf3e631b7"
  instance_type = "t2.micro"
  key_name = "x-prod-bastion-key"
  vpc_security_group_ids = [aws_security_group.x-prod-bastion-ssh-SG.id]
  subnet_id = aws_subnet.x-prod-net-db-B.id

  tags = {
    Name = "EC2-db-B"
  }
}

