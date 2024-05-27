############### Infra Variables #################
variable deployment_name {
    description = "Deployment Name for the boomi terraform deployment."
    type = string
    default = "boomi-eks-blueprint-013"
}
variable region {
    type = string
    default = "us-east-2"
}
variable aws_profile {
    type = string
}

variable availability_zones {
    description = "A list of availability zones names"
    type = list
    default = ["us-east-2a", "us-east-2b", "us-east-2c"]
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

