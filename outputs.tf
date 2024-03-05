output "profile" {
  value     = var.aws_profile
}
output "region" {
  value     = var.region
}
output "deployment_name" {
  value     = var.deployment_name
}

output "ssh_private_key" {
  value     = tls_private_key.bastion_sshkey.private_key_pem
  sensitive = true
}
output "autoscaling_group_name" {
  value     = module.asg.autoscaling_group_name
}
