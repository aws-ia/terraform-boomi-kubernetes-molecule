output "public_ids" {
  description = "public subnet ids"
  value       = "${ module.vpc.public_subnets}"
}

output "private_ids" {
  description = "private subnet ids"
  value       = "${ module.vpc.private_subnets}"
}