resource "aws_key_pair" "bastion_key" {
  key_name   = var.deploymentName
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = var.deploymentName
  cidr = "10.0.0.0/16"

  create_vpc = true

  azs = ["us-west-2a", "us-west-2b", "us-west-2c","us-west-2d"]
  private_subnets = ["10.0.0.0/19","10.0.32.0/19","10.0.64.0/19","10.0.96.0/19"]
  public_subnets  = ["10.0.128.0/20","10.0.144.0/20","10.0.160.0/20","10.0.224.0/19"]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module boomi-eks-molecule {
    source = "../.."
    bastion_key_name = aws_key_pair.bastion_key.key_name   
    
    boomi_script_location = "../../" 

    BoomiUsername = var.BoomiUsername
    BoomiAccountID = var.BoomiAccountID
    BoomiMFAInstallToken = var.BoomiMFAInstallToken
    BoomiPassword = ""
    aws_profile = var.aws_profile

    create_new_vpc = false
    existing_vpcId = "vpc-04cb528782575c615"
    existing_private_subnetsIds = ["subnet-0fc5e58ba8a5a7a87","subnet-0abfd7a4089b04060","subnet-07835580a24d2cc58","subnet-05be978b816a530fc"]
    bastion_security_group_id = ""
    existing_public_subnetsIds = ["subnet-0557d0ada982c2fec","subnet-064f712e8abe5984a","subnet-001e92616bb19a8c6","subnet-05b2ab646feefe9d4"] 
    availabilityZones = ["us-west-2a", "us-west-2b", "us-west-2c","us-west-2d"]

    cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
}