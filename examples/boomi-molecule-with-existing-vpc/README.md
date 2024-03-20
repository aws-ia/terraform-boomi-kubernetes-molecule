<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_boomi-eks-molecule"></a> [boomi-eks-molecule](#module\_boomi-eks-molecule) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 4.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | n/a | `string` | n/a | yes |
| <a name="input_boomi_account_id"></a> [boomi\_account\_id](#input\_boomi\_account\_id) | n/a | `string` | n/a | yes |
| <a name="input_boomi_install_token"></a> [boomi\_install\_token](#input\_boomi\_install\_token) | n/a | `string` | n/a | yes |
| <a name="input_boomi_username"></a> [boomi\_username](#input\_boomi\_username) | n/a | `string` | n/a | yes |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | ############## Infra Variables ################# | `string` | `"boomi-eks-blueprint"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-west-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group"></a> [autoscaling\_group](#output\_autoscaling\_group) | n/a |
| <a name="output_bastion_host_key_file"></a> [bastion\_host\_key\_file](#output\_bastion\_host\_key\_file) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
<!-- END_TF_DOCS -->