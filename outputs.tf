# OUTPUTS
output "jenkins_setup_vpc_id" {
  value = module.networking.vpc_id
}

output "jenkins_setup_public_subnets" {
  value = module.networking.public_subnet_ids
}

output "jenkins_setup_public_subnet_cidr_block" {
  value = module.networking.public_subnet_cidr_blocks
}

output "ec2_http_ssh_sg_id" {
  value = module.security_groups.sg_ec2_ssh_http_id
}

output "ec2_jenkins_sg_id" {
  value = module.security_groups.sg_ec2_jenkins_http_id

}

output "jenkins_ec2_instance_id" {
  value = module.jenkins.jenkins_ec2_instance_id
}

output "jenkins_ec2_instance_public_ip" {
  value = module.jenkins.jenkins_ec2_instance_public_ip
}

output "ssh_connection_string_for_ec2" {
  value = module.jenkins.ssh_connection_string_for_ec2
}

output "jenkins_load_balancer_dns_name" {
  value = module.load_balancer.load_balancer_dns_name
}