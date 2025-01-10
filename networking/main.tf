variable "vpc_cidr" {}
variable "vpc_name" {}
variable "cidr_public_subnet" {}
variable "eu_availability_zone" {}
variable "cidr_private_subnet" {}

## OUTPUTS
output "vpc_id" {
  value = aws_vpc.jenkins_setup_vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.jenkins_setup_public_subnet.*.id
}

output "public_subnet_cidr_blocks" {
  value = aws_subnet.jenkins_setup_public_subnet.*.cidr_block
}

# CREATE VPC
resource "aws_vpc" "jenkins_setup_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.vpc_name,
  }
}

# CREATE PUBLIC SUBNET
resource "aws_subnet" "jenkins_setup_public_subnet" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.jenkins_setup_vpc.id
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)


  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"
  }
}

# CREATE PRIVATE SUBNET
resource "aws_subnet" "jenkins_setup_private_subnet" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.jenkins_setup_vpc.id
  cidr_block        = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.eu_availability_zone, count.index)

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"
  }
}

# SETUP INTERNET GATEWAY
resource "aws_internet_gateway" "jenkins_setup_public_internet_igw" {
  vpc_id = aws_vpc.jenkins_setup_vpc.id
  tags = {
    Name = "jenkins-setup-igw"
  }
}


# CREATE ROUTE TABLE (PUBLIC)
resource "aws_route_table" "jenkins_setup_public_rt" {
  vpc_id = aws_vpc.jenkins_setup_vpc.id

  tags = {
    Name = "jenkins_setup_public_rt"
  }
}

# CREATE ROUTE (PUBLIC)
resource "aws_route" "public_igw_route" {
  route_table_id         = aws_route_table.jenkins_setup_public_rt.id
  destination_cidr_block = "0.0.0.0/0" # Internet
  gateway_id             = aws_internet_gateway.jenkins_setup_public_internet_igw.id
}

# ASSOCIATE PUBLIC ROUTE TABLE TO PUBLIC SUBNET
resource "aws_route_table_association" "jenkins_setup_public_subnet_association" {
  count          = length(aws_subnet.jenkins_setup_public_subnet)
  subnet_id      = aws_subnet.jenkins_setup_public_subnet[count.index].id
  route_table_id = aws_route_table.jenkins_setup_public_rt.id
}

# CREATE ROUTE TABLE (PRIVATE)
resource "aws_route_table" "jenkins_setup_private_rt" {
  vpc_id = aws_vpc.jenkins_setup_vpc.id

  tags = {
    Name = "jenkins_setup_private_rt"
  }
}

# ASSOCIATE PRIVATE ROUTE TABLE TO PRIVATE SUBNET
resource "aws_route_table_association" "jenkins_setup_private_subnet_association" {
  count          = length(aws_subnet.jenkins_setup_private_subnet)
  subnet_id      = aws_subnet.jenkins_setup_private_subnet[count.index].id
  route_table_id = aws_route_table.jenkins_setup_private_rt.id
}