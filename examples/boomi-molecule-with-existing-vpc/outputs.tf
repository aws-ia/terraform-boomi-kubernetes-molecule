output "kubectl_command" {
  description = "Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig"
  value       = "${module.boomi-eks-molecule.configure_kubectl}"
}