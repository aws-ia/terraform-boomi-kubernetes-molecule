output "profile" {
  value     = var.aws_profile
  description = "AWS Profile provided as input for deployment"
}
output "region" {
  value     = var.region
  description = "AWS region provided as input for deployment"
}
output "deployment_name" {
  value     = var.deployment_name
  description = "Deployment Name provided as input"
}

output "ssh_private_key" {
  value     = tls_private_key.bastion_sshkey.private_key_pem
  sensitive = true
  description = "generated ssh private key for bastion host"
}
output "autoscaling_group_name" {
  value     = module.asg.autoscaling_group_name
  sensitive = true
  description = "asg for bastion host"
}
