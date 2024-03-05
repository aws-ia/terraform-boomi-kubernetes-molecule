############### Infra Variables #################
variable deployment_name {
    description = "Deployment Name for the boomi terraform deployment."
    type = string
    default = "boomi-eks-blueprint"
}
variable region {
    description = "Region for the EKS deployment."
    type = string
    default = "us-west-2"
}
variable aws_profile {
    description = "AWS profile for the deployment."
    type = string
}

variable vpc_cidr {
    description = "The IPv4 CIDR block for the VPC."
    type = string
    default = "10.0.0.0/16"
}

variable availability_zones {
    description = "A list of availability zones names"
    type = list
    default = ["us-west-2a", "us-west-2b", "us-west-2c","us-west-2d"]
}

variable private_subnets {
    description = "A list of private subnets CIDR range"
    type = list
    default = ["10.0.0.0/19","10.0.32.0/19","10.0.64.0/19","10.0.96.0/19"]
}

variable public_subnets {
    description = "A list of public subnets CIDR range"
    type = list
    default = ["10.0.128.0/20","10.0.144.0/20","10.0.160.0/20","10.0.224.0/19"]
}

variable bastion_ami_id {
    description = "AMI ID for Bastion Host"
    type = string
    default = "ami-07dfed28fcf95241c"
}

variable bastion_remote_access_cidr{
    description = "CIDR Range for bastion Host"
    type = string
    default = "0.0.0.0/0"
}

variable "create_new_vpc" {
  description = "If set to true, will create new VPC. If set to false, the existing provided vpc is used"
  default = false
  type   = bool
}

variable existing_vpc_id {
    description = "VPC ID for existing VPC"
    type = string
}

variable existing_private_subnets_ids {
    description = "List of private subnet ids"
    type = list  
}

variable existing_public_subnets_ids {
    description = "List of public subnet ids"
    type = list  
}

variable bastion_security_group_id {
    description = "Security Group ID of bastion host. This will be added to EKS for access from Bastion Host."
    type = string
}

variable cluster_version {
    type = string
    default = "1.27"
    description = "EKS Cluster Version"
    validation {
        condition     = contains(["1.25", "1.26","1.27"], var.cluster_version)
        error_message = "Valid values for var: cluster_version are (1.25, 1.26,1.27)."
    } 
}

variable "kubectl_version" {
  type = map
  description = "kubectl version for accessing EKS Cluster"
  default = {
    1.25 = "1.25.9/2023-05-11"
    1.26 = "1.26.4/2023-05-11"
    1.27 = "1.27.1/2023-04-19"
  }
}

############### Boomi Account Variables #################

variable boomi_username {
    description = "Boomi Username"
    type = string
}
variable boomi_account_id {
    description = "Boomi Account ID"
    type = string
}
variable boomi_install_token {
    description = "Boomi AtomSphere API Tokens"
    type = string
}