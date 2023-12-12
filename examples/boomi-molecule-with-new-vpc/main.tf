resource "aws_key_pair" "bastion_key" {
  key_name   = var.deploymentName
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

module boomi-eks-molecule {
    source = "../.."
    aws_profile = "boomi-runtime-sandbox-admin"
    bastion_key_name = aws_key_pair.bastion_key.key_name

    vpcCidr = "10.0.0.0/16"
    availabilityZones = ["us-west-2a", "us-west-2b", "us-west-2c","us-west-2d"]
    private_subnets = ["10.0.0.0/19","10.0.32.0/19","10.0.64.0/19","10.0.96.0/19"]
    public_subnets = ["10.0.128.0/20","10.0.144.0/20","10.0.160.0/20","10.0.224.0/19"]
    bastion_ami_id = "ami-07dfed28fcf95241c"
    create_new_vpc = true
    cluster_version = "1.26"
    boomi_script_location = "../../"
    BoomiUsername = var.BoomiUsername
    BoomiAccountID = var.BoomiAccountID
    BoomiMFAInstallToken = var.BoomiMFAInstallToken
    BoomiPassword = ""
    cluster_endpoint_public_access_cidrs = ["3.109.64.63/32"]

    existing_vpcId = ""
    existing_private_subnetsIds = []
    bastion_security_group_id = ""
    existing_public_subnetsIds = []
    
}