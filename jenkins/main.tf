variable "ami_id" {}
variable "instance_type" {}
variable "tag_name" {}
variable "public_key" {}
variable "subnet_id" {}
variable "sg_for_jenkins" {}
variable "enable_public_ip_address" {}
variable "user_data_install_jenkins" {}


# OUTPUTS
output "ssh_connection_string_for_ec2" {
  value = format("%s%s", "ssh ubuntu@", aws_instance.jenkins_instance.public_ip)
}

output "jenkins_ec2_instance_id" {
  value = aws_instance.jenkins_instance.id
}

output "jenkins_ec2_instance_public_ip" {
  value = aws_instance.jenkins_instance.public_ip
}

# create key pair resource
resource "aws_key_pair" "dev_auth" {
  key_name   = "jenkins-key"
  public_key = var.public_key
}

# create EC2 instance for Jenkins
resource "aws_instance" "jenkins_instance" {
    ami                         = var.ami_id
    instance_type               = var.instance_type
    key_name                    = aws_key_pair.dev_auth.key_name
    subnet_id                   = var.subnet_id
    vpc_security_group_ids      = var.sg_for_jenkins
    associate_public_ip_address = var.enable_public_ip_address

    tags = {
        Name = var.tag_name
    }

    user_data = var.user_data_install_jenkins

     metadata_options {
        http_endpoint = "enabled"  # Enable the IMDSv2 endpoint
        http_tokens   = "required" # Require the use of IMDSv2 tokens
    }
}