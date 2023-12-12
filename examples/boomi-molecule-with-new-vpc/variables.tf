############### Infra Variables #################
variable deploymentName {
    type = string
    default = "boomi-eks-blueprint"
}
variable region {
    type = string
    default = "us-west-2"
}
variable aws_profile {
    type = string
}

############### Boomi Account Variables #################

variable BoomiUsername {
    type = string
}
variable BoomiAccountID {
    type = string
}
variable BoomiMFAInstallToken {
    type = string
}