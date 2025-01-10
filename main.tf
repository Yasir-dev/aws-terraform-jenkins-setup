// Networking module
module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  cidr_public_subnet   = var.cidr_public_subnet
  cidr_private_subnet  = var.cidr_private_subnet
  eu_availability_zone = var.eu_availability_zone
}

# Security Groups module
module "security_groups" {
  source              = "./security_groups"
  ec2_sg_name         = "Security Group for EC2 to enable SSH(22), HTTPS(443) and HTTP(80)"
  vpc_id              = module.networking.vpc_id
  ec2_jenkins_sg_name = "Security Group for Jenkins to enable port 8080"
}

# Jenkins module
module "jenkins" {
  source                    = "./jenkins"
  ami_id                    = data.aws_ami.server_ami.id
  instance_type             = "t2.medium"
  tag_name                  = "Jenkins:Ubuntu Linux EC2"
  public_key                = file(var.public_key)
  subnet_id                 = tolist(module.networking.public_subnet_ids)[0]
  sg_for_jenkins            = [module.security_groups.sg_ec2_ssh_http_id, module.security_groups.sg_ec2_jenkins_http_id]
  enable_public_ip_address  = true
  user_data_install_jenkins = templatefile("./jenkins-runner-script/jenkins-installer.sh", {})
}

# Load Balancer target Group module
module "load_balancer_target_group" {
  source                   = "./load_balancer_target_group"
  lb_target_group_name     = "jenkins-lb-target-group"
  lb_target_group_port     = 8080
  lb_target_group_protocol = "HTTP"
  vpc_id                   = module.networking.vpc_id
  ec2_instance_id          = module.jenkins.jenkins_ec2_instance_id
}

# Load Balancer module
module "load_balancer" {
  source                                = "./load_balancer"
  load_balancer_name                    = "jenkins-lb"
  is_external                           = false
  load_balancer_type                    = "application"
  sg_enable_ssh_https                   = module.security_groups.sg_ec2_ssh_http_id
  subnet_ids                            = tolist(module.networking.public_subnet_ids)
  load_balancer_target_group_arn        = module.load_balancer_target_group.jenkins_lb_target_group_arn
  ec2_instance_id                       = module.jenkins.jenkins_ec2_instance_id
  load_balancer_listener_port           = 80
  load_balancer_listener_protocol       = "HTTP"
  load_balancer_listener_default_action = "forward"
  load_balancer_target_group_attachment_port = 8080
}