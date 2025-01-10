variable "lb_target_group_name" {}
variable "lb_target_group_port" {}
variable "lb_target_group_protocol" {}
variable "vpc_id" {}
variable "ec2_instance_id" {}

# OUTPUTS
output "jenkins_lb_target_group_arn" {
  value = aws_lb_target_group.jenkins_lb_target_group.arn
}

# CREATE TARGET GROUP FOR LOAD BALANCER 
# see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "jenkins_lb_target_group" {
    name     = var.lb_target_group_name
    port     = var.lb_target_group_port
    protocol = var.lb_target_group_protocol
    vpc_id   = var.vpc_id
    health_check {
        path = "/login"
        port = 8080
        healthy_threshold = 5 # The number of consecutive health checks successes required before considering an unhealthy target healthy.
        unhealthy_threshold = 2 # The number of consecutive health check failures required before considering a target unhealthy.
        timeout = 2 # The amount of time, in seconds, during which no response means a failed health check.
        interval = 5 # The approximate amount of time between health checks of an individual target
        matcher = "200"  # HTTP 200
    }
}

# attach EC2 instance to target group
# see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
# resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
#   target_group_arn = aws_lb_target_group.jenkins_lb_target_group.arn
#   target_id        = var.ec2_instance_id
#   port             = 8080
# }