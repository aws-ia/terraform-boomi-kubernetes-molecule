############### Infra Variables #################
variable deployment_name {
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

variable boomi_username {
    type = string
}
variable boomi_account_id {
    type = string
}
variable boomi_install_token {
    type = string
}