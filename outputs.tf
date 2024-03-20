output "autoscaling_group_name" {
  value = module.asg.autoscaling_group_name
  description = "Bastion host autoscaling group. This can be used to filter bastion host instance"
}

output "bastion_host_key_file" {
  value = "s3://${module.s3_bucket.s3_bucket_id}/${local.name}-keypair-${var.region}"
  description = "Key file used to connect to bastion host as ec2-user"
}

output "bastion_host_region" {
    value = module.s3_bucket.s3_bucket_region
    description = "Region of the bastion host"
}

