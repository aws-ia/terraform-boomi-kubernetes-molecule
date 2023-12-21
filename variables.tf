############### Infra Variables #################
variable deployment_name {
    description = "Deployment Name for the boomi terraform deployment"
    type = string
    default = "boomi-eks-blueprint"
}
variable region {
    description = "Region for the EKS deployment"
    type = string
    default = "us-west-2"
}
variable aws_profile {
    description = "AWS profile for the deployment, if needed"
    type = string
}

variable vpc_cidr{
    type = string
    default = "10.0.0.0/16"
}

variable boomi_script_location {
    type = string
    default = ""
}

variable availability_zones {
    type = list
    default = ["us-west-2a", "us-west-2b", "us-west-2c","us-west-2d"]
}

variable private_subnets {
    type = list
    default = ["10.0.0.0/19","10.0.32.0/19","10.0.64.0/19","10.0.96.0/19"]
}

variable public_subnets {
    type = list
    default = ["10.0.128.0/20","10.0.144.0/20","10.0.160.0/20","10.0.224.0/19"]
}

variable bastion_key_name {
    type = string
}

variable bastion_ami_id {
    type = string
    default = "ami-07dfed28fcf95241c"
}

variable cluster_endpoint_public_access_cidrs{
    type = string
    default = "0.0.0.0/0"
}

variable bastion_remote_access_cidr{
    type = string
    default = "0.0.0.0/0"
}

variable "create_new_vpc" {
  description = "If set to true, will create new VPC. If set to false, the existing provided vpc is used"
  default = false
  type   = bool
}

variable existing_vpc_id {
    type = string
}

variable existing_private_subnets_ids {
    type = list  
}

variable existing_public_subnets_ids {
    type = list
}

variable bastion_security_group_id {
    type = string
}


variable cluster_version {
    type = string
    default = "1.26"
    validation {
        condition     = contains(["1.25", "1.26","1.27"], var.cluster_version)
        error_message = "Valid values for var: cluster_version are (1.25, 1.26,1.27)."
    } 
}

variable "kubectl_version" {
  type = map
  default = {
    1.25 = "1.25.9/2023-05-11"
    1.26 = "1.26.4/2023-05-11"
    1.27 = "1.27.1/2023-04-19"
  }
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
variable boomi_password {
    type = string
}