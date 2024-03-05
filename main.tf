data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

data "aws_subnet" "aws_private_subnet_cidr" {
  for_each = var.create_new_vpc ? [] : toset(var.existing_private_subnets_ids)
  id       = each.value
}

data "aws_caller_identity" "current" {}

locals {
  name   = var.deployment_name
  tags = {
    Name  = local.name
    Type = "EKS Blueprint Terraform"
    BoomiContact = "eks-quickstart"
  }

  username = "BOOMI_TOKEN.${var.boomi_username}"
  password = var.boomi_install_token
  token_type =  "Molecule"
  token_timeout = 90  

  vpc_id     = var.create_new_vpc ? module.vpc.vpc_id : var.existing_vpc_id
  private_subnet_ids = var.create_new_vpc ? module.vpc.private_subnets : var.existing_private_subnets_ids
  public_subnet_ids = var.create_new_vpc ? module.vpc.public_subnets : var.existing_public_subnets_ids
  private_subnet_cidrs  = var.create_new_vpc ? var.private_subnets : values(data.aws_subnet.aws_private_subnet_cidr)[*].cidr_block  
  bastion_security_group_id = var.create_new_vpc ? module.bastion_sg.security_group_id : var.bastion_security_group_id

  account_id = data.aws_caller_identity.current.account_id
}

################################################################################
# Boomi License validation
################################################################################

data "aws_iam_policy_document" "lambda_cloudwatchlogs_kms_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }

    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${var.region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = ["*"]
  }
}

resource "aws_kms_key" "lambda_kms_key" {
  description             = "KMS key for EKS Blueprint Lambda validation function"
  deletion_window_in_days = 10
  policy = data.aws_iam_policy_document.lambda_cloudwatchlogs_kms_policy.json
  enable_key_rotation = true
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"
  version = "6.5.0"
  function_name = "boomi_license_validation"
  description   = "Verifies account has available molecule licenses"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  tracing_mode = "Active"

  source_path = "${path.module}/boomi-license-validation/"
  
  cloudwatch_logs_kms_key_id = aws_kms_key.lambda_kms_key.arn
  vpc_subnet_ids = local.private_subnet_ids
}

data "aws_lambda_invocation" "boomi_license_validation" {
  function_name = "boomi_license_validation"
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

#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "efs_driver_policy" {
    name  = "${local.name}-efs-driver-policy"
    policy = file("aws-policy.json")
}

resource "aws_iam_role" "efs_driver_role" {
  name               = "${local.name}-efs-driver-role"
  managed_policy_arns = [aws_iam_policy.efs_driver_policy.arn]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect": "Allow",
			  "Principal": {
				  "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
			  },
			  "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringLike": {
            "${module.eks.oidc_provider}:sub": "system:serviceaccount:kube-system:efs-csi-*",
            "${module.eks.oidc_provider}:aud": "sts.amazonaws.com"
          }
			  }
      },
    ]
  })
}

#tfsec:ignore:aws-eks-enable-control-plane-logging
#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name                   = local.name
  cluster_version                = var.cluster_version

  vpc_id = local.vpc_id
  control_plane_subnet_ids = concat(local.private_subnet_ids)
  subnet_ids = local.private_subnet_ids

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

  enable_cluster_creator_admin_permissions = true
  authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    bastion_host = {
      kubernetes_groups = []
      principal_arn     = module.asg.iam_role_arn

      policy_associations = {
        cluster_admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type       = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.xlarge"]

      min_size     = 3
      max_size     = 4
      desired_size = 3
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  tags = local.tags
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

#tfsec:ignore:aws-ec2-no-public-egress-sgr
module "bastion_sg" {
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
      cidr_blocks = "0.0.0.0/0"
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

resource "aws_iam_policy" "bastion_host_policy" {
  name        = "bastion_host_policy"
  description = "IAM Policy for Bastion Host EKS access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
            "eks:DescribeCluster",
            "eks:DescribeUpdate",
            "eks:ListUpdates",
            "eks:UpdateClusterVersion",
            "eks:CreateAddon",
            "secretsmanager:GetSecretValue",
            "iam:PassRole"
        ]
        Effect   = "Allow"
        Resource = [
          module.eks.cluster_arn,
          aws_secretsmanager_secret.eks-blueprint-secret.arn,
          aws_iam_role.efs_driver_role.arn
        ]
      },
    ]
  })
  depends_on = [
    module.eks,
    aws_secretsmanager_secret.eks-blueprint-secret,
    aws_iam_role.efs_driver_role
  ]
}

#tfsec:ignore:aws-s3-enable-bucket-logging
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.1.0"

  bucket = "${local.name}-artifact-bucket"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "AES256"
      }
    }
  }
}

resource "tls_private_key" "bastion_sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_host_keypair" {
  key_name   = "${local.name}-keypair-${var.region}"
  public_key = tls_private_key.bastion_sshkey.public_key_openssh

  tags = local.tags
}

resource "aws_s3_object" "bastion_host_keypair" {
  bucket  = "${local.name}-artifact-bucket"
  key     = "${local.name}-keypair-${var.region}"
  content = tls_private_key.bastion_sshkey.private_key_pem
  etag = md5(tls_private_key.bastion_sshkey.private_key_pem)
  depends_on = [module.s3_bucket]
}

resource "aws_s3_object" "boomi_molecule" {
  bucket  = "${local.name}-artifact-bucket"
  key     = "${local.name}-boomi-k8s-molecule"
  source = "boomi-k8s-molecule-0.1.0.tgz"
  etag = md5(tls_private_key.bastion_sshkey.private_key_pem)
  depends_on = [module.s3_bucket]
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
  #vpc_zone_identifier       = module.vpc.public_subnets

  vpc_zone_identifier = local.public_subnet_ids
  # Launch template
  launch_template_name        = "BastionHost-for-eks-blueprint"
  launch_template_description = "BastionHost-for-eks-blueprint"
  update_default_version      = true

  autoscaling_group_tags = local.tags

  key_name = "${local.name}-keypair-${var.region}"

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
    BastionHostPolicy = aws_iam_policy.bastion_host_policy.arn
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
      security_groups       = [module.bastion_sg.security_group_id]
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

#tfsec:ignore:aws-ssm-secret-use-customer-key
resource "aws_secretsmanager_secret" "eks_blueprint_secret" {
  name = "${local.name}-eks-blueprint-v1"
  recovery_window_in_days = 0
  #kms_key_id = aws_kms_key.lambda_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "eks_blueprint_credentials" {
  secret_id = aws_secretsmanager_secret.eks_blueprint_secret.id

  secret_string = jsonencode(
    {
      efs_driver_role_arn = aws_iam_role.efs_driver_role.arn
      efs_id = module.efs.id
      boomi_account_id  = var.boomi_account_id
      boomi_username = var.boomi_username      
      install_token = jsondecode(data.aws_lambda_invocation.boomi_license_validation.result)["token"] 
    }
  )
}
