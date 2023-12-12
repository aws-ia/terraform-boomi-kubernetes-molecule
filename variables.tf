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

variable vpcCidr {
    type = string
    default = "10.0.0.0/16"
}

variable boomi_script_location {
    type = string
    default = ""
}

variable availabilityZones {
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
    type = list
    default = ["0.0.0.0/0"]
}

variable "create_new_vpc" {
  description = "If set to true, will create new VPC. If set to false, the existing provided vpc is used"
  default = false
  type   = bool
}

variable existing_vpcId {
    type = string
}

variable existing_private_subnetsIds {
    type = list  
}

variable existing_public_subnetsIds {
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

variable BoomiUsername {
    type = string
}
variable BoomiAccountID {
    type = string
}
variable BoomiMFAInstallToken {
    type = string
}
variable BoomiPassword {
    type = string
}