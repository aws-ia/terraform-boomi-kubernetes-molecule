module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = var.deployment_name
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
    bastion_key_name = ""
    
    boomi_script_location = "../../" 

    boomi_username = var.boomi_username
    boomi_account_id = var.boomi_account_id
    boomi_install_token = var.boomi_install_token
    boomi_password = ""
    aws_profile = var.aws_profile

    create_new_vpc = false
    existing_vpc_id = module.vpc.vpc_id
    existing_private_subnets_ids = module.vpc.private_subnets
    existing_public_subnets_ids = module.vpc.public_subnets
    availability_zones = module.vpc.azs
    bastion_security_group_id = ""
}