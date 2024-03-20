output "autoscaling_group_name" {
  value = module.asg.autoscaling_group_name
}

output "bastion_host_key_file" {
  value = "s3://${module.s3_bucket.s3_bucket_id}/${local.name}-keypair-${var.region}"
}

output "bastion_host_region" {
    value = module.s3_bucket.s3_bucket_region
}

