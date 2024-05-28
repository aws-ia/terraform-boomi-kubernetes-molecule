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

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | n/a | `string` | n/a | yes |
| <a name="input_boomi_account_id"></a> [boomi\_account\_id](#input\_boomi\_account\_id) | n/a | `string` | n/a | yes |
| <a name="input_boomi_install_token"></a> [boomi\_install\_token](#input\_boomi\_install\_token) | n/a | `string` | n/a | yes |
| <a name="input_boomi_username"></a> [boomi\_username](#input\_boomi\_username) | n/a | `string` | n/a | yes |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | A list of availability zones names | `list` | <pre>[<br>  "us-east-2a",<br>  "us-east-2b",<br>  "us-east-2c"<br>]</pre> | no |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | Deployment Name for the boomi terraform deployment. | `string` | `"boomi-eks-blueprint-023"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-east-2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_autoscaling_group"></a> [autoscaling\_group](#output\_autoscaling\_group) | n/a |
| <a name="output_bastion_host_key_file"></a> [bastion\_host\_key\_file](#output\_bastion\_host\_key\_file) | n/a |
| <a name="output_region"></a> [region](#output\_region) | n/a |
<!-- END_TF_DOCS -->