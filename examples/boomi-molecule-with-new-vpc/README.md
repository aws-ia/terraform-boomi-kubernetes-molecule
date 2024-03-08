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
| <a name="input_deploymentName"></a> [deploymentName](#input\_deploymentName) | ############## Infra Variables ################# | `string` | `"boomi-eks-blueprint"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"us-west-2"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->