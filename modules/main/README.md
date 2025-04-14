<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_carbacc"></a> [carbacc](#module\_carbacc) | ../apps/carbacc | n/a |
| <a name="module_environment"></a> [environment](#module\_environment) | ../environment | n/a |
| <a name="module_esg"></a> [esg](#module\_esg) | ../apps/esg | n/a |
| <a name="module_realm"></a> [realm](#module\_realm) | ../realm | n/a |
| <a name="module_vat"></a> [vat](#module\_vat) | ../apps/vat | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_email"></a> [app\_admin\_email](#input\_app\_admin\_email) | Application admin email, must be a valid email address | `any` | n/a | yes |
| <a name="input_app_admin_first_name"></a> [app\_admin\_first\_name](#input\_app\_admin\_first\_name) | Application admin first name | `any` | n/a | yes |
| <a name="input_app_admin_initial_password"></a> [app\_admin\_initial\_password](#input\_app\_admin\_initial\_password) | Application admin initial password, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_app_admin_last_name"></a> [app\_admin\_last\_name](#input\_app\_admin\_last\_name) | Application admin last name | `any` | n/a | yes |
| <a name="input_carbacc_version"></a> [carbacc\_version](#input\_carbacc\_version) | version of carbacc to deploy | `any` | n/a | yes |
| <a name="input_container_registry"></a> [container\_registry](#input\_container\_registry) | container registry url | `string` | `"imagesdevregistry.azurecr.io"` | no |
| <a name="input_container_registry_password"></a> [container\_registry\_password](#input\_container\_registry\_password) | container registry password, must not be empty | `any` | n/a | yes |
| <a name="input_container_registry_username"></a> [container\_registry\_username](#input\_container\_registry\_username) | container registry username, must not be empty | `any` | n/a | yes |
| <a name="input_customer"></a> [customer](#input\_customer) | shorthand abbrieviation for customer name, must only contain lowercase letters and numbers | `any` | n/a | yes |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | database admin password, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_database_sku"></a> [database\_sku](#input\_database\_sku) | database sku, must be a valid Azure database sku | `string` | `"B_Standard_B2s"` | no |
| <a name="input_database_storage"></a> [database\_storage](#input\_database\_storage) | database storage in MB, must be a valid Azure database storage size | `string` | `"32768"` | no |
| <a name="input_database_user"></a> [database\_user](#input\_database\_user) | database admin user, must only contain lowercase letters and numbers | `string` | `"postgres"` | no |
| <a name="input_emailpassword"></a> [emailpassword](#input\_emailpassword) | password for email user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_esg_version"></a> [esg\_version](#input\_esg\_version) | version of esg to deploy | `any` | n/a | yes |
| <a name="input_include_carbacc"></a> [include\_carbacc](#input\_include\_carbacc) | Include CARBACC | `bool` | `false` | no |
| <a name="input_include_esg"></a> [include\_esg](#input\_include\_esg) | Include ESG | `bool` | `false` | no |
| <a name="input_include_vat"></a> [include\_vat](#input\_include\_vat) | Include VAT | `bool` | `false` | no |
| <a name="input_keycloak_admin_password"></a> [keycloak\_admin\_password](#input\_keycloak\_admin\_password) | password for Keycloak admin user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_keycloak_admin_user"></a> [keycloak\_admin\_user](#input\_keycloak\_admin\_user) | Keycloak admin user, must only contain lowercase letters and numbers | `string` | `"admin"` | no |
| <a name="input_location"></a> [location](#input\_location) | location of the resource group, must be a valid Azure location | `string` | `"northeurope"` | no |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | maximum number of replicas, must be a number | `number` | `10` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | minimum number of replicas, must be a number, use 0 to allow scaling to 0 to reduce costs | `number` | `0` | no |
| <a name="input_rabbitmq_image"></a> [rabbitmq\_image](#input\_rabbitmq\_image) | docker image for rabbitmq | `string` | `"rabbitmq:3.12.6"` | no |
| <a name="input_rabbitmq_password"></a> [rabbitmq\_password](#input\_rabbitmq\_password) | password for RabbitMQ default user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_rabbitmq_user"></a> [rabbitmq\_user](#input\_rabbitmq\_user) | RabbitMQ default user, must only contain lowercase letters and numbers | `string` | `"rabbitmq"` | no |
| <a name="input_reportingpassword"></a> [reportingpassword](#input\_reportingpassword) | password for reporting user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_smtp_from"></a> [smtp\_from](#input\_smtp\_from) | SMTP from address, must be a valid email address | `any` | n/a | yes |
| <a name="input_smtp_host"></a> [smtp\_host](#input\_smtp\_host) | SMTP host | `any` | n/a | yes |
| <a name="input_smtp_password"></a> [smtp\_password](#input\_smtp\_password) | SMTP password | `any` | n/a | yes |
| <a name="input_smtp_port"></a> [smtp\_port](#input\_smtp\_port) | SMTP port, must be a number | `any` | n/a | yes |
| <a name="input_smtp_username"></a> [smtp\_username](#input\_smtp\_username) | SMTP username | `any` | n/a | yes |
| <a name="input_vat_version"></a> [vat\_version](#input\_vat\_version) | version of esg to deploy | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_url"></a> [api\_url](#output\_api\_url) | n/a |
| <a name="output_esg_frontend_url"></a> [esg\_frontend\_url](#output\_esg\_frontend\_url) | n/a |
| <a name="output_user_management_url"></a> [user\_management\_url](#output\_user\_management\_url) | n/a |
| <a name="output_vat_frontend_url"></a> [vat\_frontend\_url](#output\_vat\_frontend\_url) | n/a |
<!-- END_TF_DOCS -->