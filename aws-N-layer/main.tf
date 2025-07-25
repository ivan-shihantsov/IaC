
provider "aws" {
 region     = "eu-central-1"
}

resource "aws_vpc" "vpc-x-prod" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-x-prod"
  }
}

