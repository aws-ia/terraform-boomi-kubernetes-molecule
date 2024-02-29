output "ssh_private_key" {
  value     = tls_private_key.bastion_sshkey.private_key_pem
  sensitive = true
}

output "boomi_install_token" {
  value     = jsondecode(data.aws_lambda_invocation.boomi_license_validation.result)["token"]
  sensitive = true
}

output "profile" {
  value     = var.aws_profile
}

output "region" {
  value     = var.region
}

output "autoscaling_group_name" {
  value     = module.asg.autoscaling_group_name
}

output "efs_id" {
  value     = module.efs.id
}

output "deployment_name" {
  value     = var.deployment_name
}

output "boomi_username" {
  value     = var.boomi_username
  sensitive = true
}

output "boomi_account_id" {
  value     = var.boomi_account_id
  sensitive = true
}
