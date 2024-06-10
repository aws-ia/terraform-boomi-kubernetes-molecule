output "autoscaling_group" {
  value = "${module.boomi-eks-molecule.autoscaling_group_name}"
}

output "bastion_host_key_file" {
  value = "${module.boomi-eks-molecule.bastion_host_key_file}"
}

output "region" {
  value = "${module.boomi-eks-molecule.bastion_host_region}"
}