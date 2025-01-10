variable "ec2_sg_name" {}
variable "vpc_id" {}
variable "ec2_jenkins_sg_name" {}

# Outputs 
output "sg_ec2_ssh_http_id" {
  value = aws_security_group.security_group_http_ssh.id
}

output "sg_ec2_jenkins_http_id" {
  value = aws_security_group.security_group_http_jenkins.id
}

# create security group for EC2 to allow SSH, HTTP, HTTPS
# security group is like a virtual firewall that controls inbound and outbound traffic for instances
resource "aws_security_group" "security_group_http_ssh" {
  name        = var.ec2_sg_name
  description = "Allow SSH, HTTP, HTTPS inbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SG to allow Port 22, 80, 443"
  }
}

# inbound/ingress traffic for jenkins_setup_security_group
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_anywhere" {
  security_group_id = aws_security_group.security_group_http_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22

  tags = {
    Name = "Allow SSH from anywhere"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_80_from_anywhere" {
  security_group_id = aws_security_group.security_group_http_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80

  tags = {
    Name = "Allow HTTP on port 80 from anywhere"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_443_from_anywhere" {
  security_group_id = aws_security_group.security_group_http_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

  tags = {
    Name = "Allow HTTPS on port 443 from anywhere"
  }
}

# outbound/egress traffic for jenkins_setup_security_group
resource "aws_vpc_security_group_egress_rule" "allow_all_for_outbound" {
  security_group_id = aws_security_group.security_group_http_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0

  tags = {
    Name = "Allow all internet access from outbound"
  }
}

# create security group for Jenkins to allow port 8080
resource "aws_security_group" "security_group_http_jenkins" {
  name        = var.ec2_jenkins_sg_name
  description = "Allow HTTP 8080 for jenkins"
  vpc_id      = var.vpc_id

  tags = {
    Name = "SG to allow Port 8080"
  }
}

# inbound/ingress traffic for jenkins_setup_security_group
resource "aws_vpc_security_group_ingress_rule" "allow_http_8080_from_anywhere" {
  security_group_id = aws_security_group.security_group_http_jenkins.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080

  tags = {
    Name = "Allow HTTP on port 8080 from anywhere"
  }
}