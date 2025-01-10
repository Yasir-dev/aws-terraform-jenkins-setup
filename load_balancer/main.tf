variable "load_balancer_name" {}
variable "load_balancer_type" {}
variable "is_external" { default = false }
variable "sg_enable_ssh_https" {}
variable "subnet_ids" {}
variable "load_balancer_target_group_arn" {}
variable "ec2_instance_id" {}
variable "load_balancer_listener_port" {}
variable "load_balancer_listener_protocol" {}
variable "load_balancer_listener_default_action" {}
variable "load_balancer_target_group_attachment_port" {}

output "load_balancer_dns_name" {
  value = aws_lb.jenkins_load_balancer.dns_name
}

# create load balancer
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "jenkins_load_balancer" {
  name               = var.load_balancer_name
  internal           = var.is_external
  load_balancer_type = var.load_balancer_type
  security_groups    = [var.sg_enable_ssh_https]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "Jenkins Load Balancer"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "jenkins_target_group_attachment" {
  target_group_arn = var.load_balancer_target_group_arn
  target_id        = var.ec2_instance_id
  port             = var.load_balancer_target_group_attachment_port
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "jenkins_lb_listener" {
  load_balancer_arn = aws_lb.jenkins_load_balancer.arn
  port              = var.load_balancer_listener_port
  protocol          = var.load_balancer_listener_protocol

  default_action {
    type             = var.load_balancer_listener_default_action
    target_group_arn = var.load_balancer_target_group_arn
  }
}