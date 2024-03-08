module boomi-eks-molecule {
    source = "../.."

    aws_profile = var.aws_profile

    vpc_cidr = "10.0.0.0/16"
    availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c","us-west-2d"]
    private_subnets = ["10.0.0.0/19","10.0.32.0/19","10.0.64.0/19","10.0.96.0/19"]
    public_subnets = ["10.0.128.0/20","10.0.144.0/20","10.0.160.0/20","10.0.224.0/19"]

    create_new_vpc = true
    
    boomi_username = var.boomi_username
    boomi_account_id = var.boomi_account_id
    boomi_install_token = var.boomi_install_token

    existing_vpc_id = ""
    existing_private_subnets_ids = []
    bastion_security_group_id = ""
    existing_public_subnets_ids = []
    boomi_script_location = "../../"
}