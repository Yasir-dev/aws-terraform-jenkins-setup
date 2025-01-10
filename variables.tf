variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR range"
}

variable "vpc_name" {
  type        = string
  description = "VPC name for the project"
}

variable "cidr_public_subnet" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "eu_availability_zone" {
  type        = list(string)
  description = "Availability Zones"
}

variable "public_key" {
  type        = string
  description = "Public key for EC2 instance"
}