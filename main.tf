data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_subnet" "aws_private_subnet_cidr" {
  for_each = var.create_new_vpc ? [] : toset(var.existing_private_subnets_ids)
  id       = each.value
}

locals {
  name   = var.deployment_name
  tags = {
    Name  = local.name
    Type = "EKS Blueprint Terraform"
    BoomiContact = "eks-quickstart"
  }

  username = var.boomi_install_token != " " ? "BOOMI_TOKEN.${var.boomi_username}" : var.boomi_username
  password = var.boomi_install_token != " " ? var.boomi_install_token : var.boomi_password
  token_type =  "Molecule"
  token_timeout = 90  

  vpc_id     = var.create_new_vpc ? module.vpc.vpc_id : var.existing_vpc_id
  private_subnet_ids = var.create_new_vpc ? module.vpc.private_subnets : var.existing_private_subnets_ids
  public_subnet_ids = var.create_new_vpc ? module.vpc.public_subnets : var.existing_public_subnets_ids
  private_subnet_cidrs  = var.create_new_vpc ? var.private_subnets : values(data.aws_subnet.aws_private_subnet_cidr)[*].cidr_block  
  bastion_security_group_id = var.create_new_vpc ? module.bastion-sg.security_group_id : var.bastion_security_group_id
}

################################################################################
# Boomi License validation
################################################################################

resource "aws_kms_key" "lambda_kms_key" {
  description             = "KMS key for EKS Blueprint Lambda validation function"
  deletion_window_in_days = 10
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"
  function_name = "boomi-license-validation"
  description   = "Verifies account has available molecule licenses"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  tracing_mode = "Active"

  source_path = "${path.module}/boomi-license-validation/"
  
  use_existing_cloudwatch_log_group = false
  cloudwatch_logs_kms_key_id = aws_kms_key.lambda_kms_key.arn
  vpc_subnet_ids = local.private_subnet_ids
}

data "aws_lambda_invocation" "boomi-license-validation" {
  function_name = "boomi-license-validation"
  depends_on = [module.lambda_function]
  input = <<JSON
  {
    "ResourceProperties": {
      "BoomiUsername": "${local.username}",
      "BoomiPassword": "${local.password}",
      "BoomiAccountID": "${var.boomi_account_id}",
      "TokenType": "${local.token_type}",
      "TokenTimeout": "${local.token_timeout}"
    }
  }
  JSON
}


################################################################################
# EKS Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.12"
  #depends_on = [module.lambda_function_existing_package_s3]

  cluster_name                   = local.name
  cluster_version                = var.cluster_version
  cluster_endpoint_public_access = true

  cluster_endpoint_public_access_cidrs = [ var.cluster_endpoint_public_access_cidrs ]

  vpc_id = local.vpc_id
  control_plane_subnet_ids = concat(local.private_subnet_ids,local.public_subnet_ids)
  subnet_ids = local.private_subnet_ids

  manage_aws_auth_configmap = true
  cluster_security_group_additional_rules = {
    inress_ec2_tcp = {
      description                = "Access EKS from Bastion Host"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_security_group_id   = local.bastion_security_group_id
    }
  }

  aws_auth_roles = [
    {
      rolearn  = module.asg.iam_role_arn
      username = module.asg.iam_role_arn
      groups   = ["system:masters"]
    }
  ]

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.xlarge"]

      min_size     = 2
      max_size     = 4
      desired_size = 2
    }
  }

  tags = local.tags
}

################################################################################
# Kubernetes Addons
################################################################################

module "eks_blueprints_addons" {
  source = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name       = module.eks.cluster_name
  cluster_endpoint   = module.eks.cluster_endpoint
  oidc_provider_arn  = module.eks.oidc_provider_arn
  cluster_version    = module.eks.cluster_version

  eks_addons = {
    coredns    = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni    = {
      most_recent = true
    }
  }

  enable_aws_efs_csi_driver = true
  enable_metrics_server     = true  
  enable_aws_load_balancer_controller = true 
  enable_cluster_autoscaler = true
  tags = local.tags

  depends_on = [
    module.eks
  ]
}

module "efs" {
  source  = "terraform-aws-modules/efs/aws"
  version = "~> 1.0"

  creation_token = local.name
  name           = local.name

  # Mount targets / security group
  mount_targets = {
    for k, v in zipmap(var.availability_zones, local.private_subnet_ids) : k => { subnet_id = v }
  }
  security_group_description = "${local.name} EFS security group"
  security_group_vpc_id      = local.vpc_id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = local.private_subnet_cidrs
    }
  }

  tags = local.tags
}


################################################################################
# Bastion Stack
################################################################################

module "bastion-sg" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.0"
  name        = "eks-blueprint-bastion-sg"
  description = "Security group for Bastion Host - EKS Blueprint"
  vpc_id      = var.create_new_vpc ? module.vpc.vpc_id : var.existing_vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH Port"
      cidr_blocks = var.bastion_remote_access_cidr
    },
    {
      from_port   = -1
      to_port     = -1
      protocol    = "icmp"
      description = "SSH Port"
      cidr_blocks = var.bastion_remote_access_cidr
    },
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = -1
      description = "Outbound Sg Rule"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  depends_on = [
    module.vpc
  ]
}

resource "aws_iam_policy" "BastionHostPolicy" {
  name        = "BastionHostPolicy"
  description = "IAM Policy for Bastion Host EKS access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "eks:DescribeCluster",
            "eks:DescribeUpdate",
            "eks:ListUpdates",
            "eks:UpdateClusterVersion"
        ]
        Effect   = "Allow"
        Resource = module.eks.cluster_arn
      },
    ]
  })
  depends_on = [
    module.eks
  ]
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~>7.3.1"
  # Autoscaling group
  name = "BastionHost-for-eks-blueprint"

  create                 = var.create_new_vpc ? true : false
  create_launch_template = var.create_new_vpc ? true : false

  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.public_subnets

  # Launch template
  launch_template_name        = "BastionHost-for-eks-blueprint"
  launch_template_description = "BastionHost-for-eks-blueprint"
  update_default_version      = true

  autoscaling_group_tags = local.tags

  key_name = var.bastion_key_name

  image_id          = var.bastion_ami_id
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true

  user_data = base64encode(templatefile("${path.module}/boomi-userdata-scripts/userDataScript.sh", { region = var.region, cluster_name = local.name,kubectl_version =  var.kubectl_version[var.cluster_version] }))

  # IAM role & instance profile
  create_iam_instance_profile = var.create_new_vpc ? true : false
  iam_role_name               = "Bastion-Role"
  iam_role_description        = "Bastion Role to access EKS"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    AmazonEC2RoleforSSM = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    BastionHostPolicy = aws_iam_policy.BastionHostPolicy.arn
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
  }

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
    }, {
      device_name = "/dev/sda1"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  network_interfaces = [
    {
      associate_public_ip_address = true
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [module.bastion-sg.security_group_id]
    }
  ]
  
  tags = local.tags
  tag_specifications = [ 
    {
      resource_type = "instance"
      tags          = local.tags
    }
  ]
}

################################################################################
# VPC Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.4.0"

  name = local.name
  cidr = var.vpc_cidr

  create_vpc = var.create_new_vpc

  azs = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

################################################################################
# Boomi Manifest
################################################################################

resource "helm_release" "boomi_molecule" {
  name       = "boomi-atom"
  repository = "s3://terraform-boomi-kubernetes-molecule-test/charts"
  #repository = "${var.boomi_script_location}boomi-k8s-molecule-manifest"
  chart      = "boomi-k8s-molecule"
  namespace = "eks-boomi-molecule"
  create_namespace = "true"
  timeout = 360

  set {
    name = "MoleculeClusterName"
    value = "k8s-boomi-molecule"
  }
  set {
    name = "boomi_username"
    value = var.boomi_username
  }
  set {
    name = "boomi_account_id"
    value = var.boomi_account_id
  }
  set {
     name = "boomi_mfa_install_token"
     value = jsondecode(data.aws_lambda_invocation.boomi-license-validation.result)["token"]
  }
  set {
     name = "efs_id"
     value = module.efs.id
  }
  set {
     name = "base_path"
     value = local.name
  }
}

