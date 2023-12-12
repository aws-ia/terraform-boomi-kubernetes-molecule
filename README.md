<!-- BEGIN_TF_DOCS -->
# Terraform Module Project

:no\_entry\_sign: Do not edit this readme.md file. To learn how to change this content and work with this repository, refer to CONTRIBUTING.md

## Readme Content

This file will contain any instructional information about this module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_asg"></a> [asg](#module\_asg) | terraform-aws-modules/autoscaling/aws | n/a |
| <a name="module_bastion-sg"></a> [bastion-sg](#module\_bastion-sg) | terraform-aws-modules/security-group/aws | n/a |
| <a name="module_efs"></a> [efs](#module\_efs) | terraform-aws-modules/efs/aws | ~> 1.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 19.12 |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | ~> 1.0 |
| <a name="module_lambda_function"></a> [lambda\_function](#module\_lambda\_function) | terraform-aws-modules/lambda/aws | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.BastionHostPolicy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.boomi_molecule](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_lambda_invocation.boomi-license-validation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_invocation) | data source |
| [aws_subnet.aws_private_subnet_cidr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_BoomiAccountID"></a> [BoomiAccountID](#input\_BoomiAccountID) | n/a | `string` | n/a | yes |
| <a name="input_BoomiMFAInstallToken"></a> [BoomiMFAInstallToken](#input\_BoomiMFAInstallToken) | n/a | `string` | n/a | yes |
| <a name="input_BoomiPassword"></a> [BoomiPassword](#input\_BoomiPassword) | n/a | `string` | n/a | yes |
| <a name="input_BoomiUsername"></a> [BoomiUsername](#input\_BoomiUsername) | n/a | `string` | n/a | yes |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | n/a | `string` | n/a | yes |
| <a name="input_bastion_key_name"></a> [bastion\_key\_name](#input\_bastion\_key\_name) | n/a | `string` | n/a | yes |
| <a name="input_bastion_security_group_id"></a> [bastion\_security\_group\_id](#input\_bastion\_security\_group\_id) | n/a | `string` | n/a | yes |
| <a name="input_existing_private_subnetsIds"></a> [existing\_private\_subnetsIds](#input\_existing\_private\_subnetsIds) | n/a | `list` | n/a | yes |
| <a name="input_existing_public_subnetsIds"></a> [existing\_public\_subnetsIds](#input\_existing\_public\_subnetsIds) | n/a | `list` | n/a | yes |
| <a name="input_existing_vpcId"></a> [existing\_vpcId](#input\_existing\_vpcId) | n/a | `string` | n/a | yes |
| <a name="input_availabilityZones"></a> [availabilityZones](#input\_availabilityZones) | n/a | `list` | <pre>[<br>  "us-west-2a",<br>  "us-west-2b",<br>  "us-west-2c",<br>  "us-west-2d"<br>]</pre> | no |
| <a name="input_bastion_ami_id"></a> [bastion\_ami\_id](#input\_bastion\_ami\_id) | n/a | `string` | `"ami-07dfed28fcf95241c"` | no |
| <a name="input_boomi_script_location"></a> [boomi\_script\_location](#input\_boomi\_script\_location) | n/a | `string` | `""` | no |
| <a name="input_cluster_endpoint_public_access_cidrs"></a> [cluster\_endpoint\_public\_access\_cidrs](#input\_cluster\_endpoint\_public\_access\_cidrs) | n/a | `list` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_cluster_version"></a> [cluster\_version](#input\_cluster\_version) | n/a | `string` | `"1.26"` | no |
| <a name="input_create_new_vpc"></a> [create\_new\_vpc](#input\_create\_new\_vpc) | If set to true, will create new VPC. If set to false, the existing provided vpc is used | `bool` | `false` | no |
| <a name="input_deploymentName"></a> [deploymentName](#input\_deploymentName) | ############## Infra Variables ################# | `string` | `"boomi-eks-blueprint"` | no |
| <a name="input_kubectl_version"></a> [kubectl\_version](#input\_kubectl\_version) | n/a | `map` | <pre>{<br>  "1.25": "1.25.9/2023-05-11",<br>  "1.26": "1.26.4/2023-05-11",<br>  "1.27": "1.27.1/2023-04-19"<br>}</pre> | no |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets) | n/a | `list` | <pre>[<br>  "10.0.0.0/19",<br>  "10.0.32.0/19",<br>  "10.0.64.0/19",<br>  "10.0.96.0/19"<br>]</pre> | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | n/a | `list` | <pre>[<br>  "10.0.128.0/20",<br>  "10.0.144.0/20",<br>  "10.0.160.0/20",<br>  "10.0.224.0/19"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-west-2"` | no |
| <a name="input_vpcCidr"></a> [vpcCidr](#input\_vpcCidr) | n/a | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |
<!-- END_TF_DOCS -->