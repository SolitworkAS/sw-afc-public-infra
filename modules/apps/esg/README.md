<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | ~> 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.75.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | ~> 1.10.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.75.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.esg_frontend_service](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.esg_organization_module](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.esg_reporting_manager](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.esg_survey_manager](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.esg_user_management](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_update_resource.esg_organization_module](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azapi_update_resource.esg_reporting_manager](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azapi_update_resource.esg_survey_manager](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azapi_update_resource.esg_user_management](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_container_app_environment_storage.esgfiles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment_storage) | resource |
| [azurerm_postgresql_flexible_server_database.esgdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_storage_share.esgshare](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | id of the container app environment, must be a valid Azure resource id | `any` | n/a | yes |
| <a name="input_container_registry"></a> [container\_registry](#input\_container\_registry) | container registry url | `string` | `"imagesdevregistry.azurecr.io"` | no |
| <a name="input_container_registry_password"></a> [container\_registry\_password](#input\_container\_registry\_password) | container registry password, must not be empty | `any` | n/a | yes |
| <a name="input_container_registry_username"></a> [container\_registry\_username](#input\_container\_registry\_username) | container registry username, must not be empty | `any` | n/a | yes |
| <a name="input_customer"></a> [customer](#input\_customer) | shorthand abbrieviation for customer name, must only contain lowercase letters and numbers | `string` | `"customer"` | no |
| <a name="input_database_database"></a> [database\_database](#input\_database\_database) | database name, must only contain lowercase letters, numbers and dashes | `string` | `"esg-db"` | no |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | database admin password, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_database_server_id"></a> [database\_server\_id](#input\_database\_server\_id) | database server id (azure resource id) | `any` | n/a | yes |
| <a name="input_database_server_url"></a> [database\_server\_url](#input\_database\_server\_url) | database server url | `any` | n/a | yes |
| <a name="input_database_user"></a> [database\_user](#input\_database\_user) | database admin user, must only contain lowercase letters and numbers | `any` | n/a | yes |
| <a name="input_emailpassword"></a> [emailpassword](#input\_emailpassword) | password for email user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_esg_version"></a> [esg\_version](#input\_esg\_version) | version of esg to deploy | `any` | n/a | yes |
| <a name="input_keycloak_client_id_esg"></a> [keycloak\_client\_id\_esg](#input\_keycloak\_client\_id\_esg) | keycloak client id, must only contain lowercase letters, numbers and dashes | `string` | `"afc-esg"` | no |
| <a name="input_keycloak_realm"></a> [keycloak\_realm](#input\_keycloak\_realm) | Keycloak realm, must only contain lowercase letters and numbers | `string` | `"customera"` | no |
| <a name="input_keycloak_url"></a> [keycloak\_url](#input\_keycloak\_url) | Keycloak url, must be a valid url (fully qualified domain name) | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | location of the resource group, must be a valid Azure location | `any` | n/a | yes |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | maximum number of replicas, must be a number | `number` | `10` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | minimum number of replicas, must be a number, use 0 to allow scaling to 0 to reduce costs | `number` | `0` | no |
| <a name="input_rabbitmq_host"></a> [rabbitmq\_host](#input\_rabbitmq\_host) | url of the rabbitmq service | `any` | n/a | yes |
| <a name="input_rabbitmq_image"></a> [rabbitmq\_image](#input\_rabbitmq\_image) | docker image for rabbitmq | `string` | `"rabbitmq:3.12.6"` | no |
| <a name="input_rabbitmq_password"></a> [rabbitmq\_password](#input\_rabbitmq\_password) | password for RabbitMQ default user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_rabbitmq_user"></a> [rabbitmq\_user](#input\_rabbitmq\_user) | RabbitMQ default user, must only contain lowercase letters and numbers | `any` | n/a | yes |
| <a name="input_reportingpassword"></a> [reportingpassword](#input\_reportingpassword) | password for reporting user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | id of the resource group, must be a valid Azure resource id | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | name of the resource group, must only contain lowercase letters, numbers and dashes | `any` | n/a | yes |
| <a name="input_storage_access_tier"></a> [storage\_access\_tier](#input\_storage\_access\_tier) | storage access tier, must be a valid Azure storage access tier | `string` | `"Hot"` | no |
| <a name="input_storage_account_name_esg"></a> [storage\_account\_name\_esg](#input\_storage\_account\_name\_esg) | name of the storage account, must only contain lowercase letters, numbers and dashes | `any` | n/a | yes |
| <a name="input_storage_primary_access_key_esg"></a> [storage\_primary\_access\_key\_esg](#input\_storage\_primary\_access\_key\_esg) | storage primary access key, must not be empty | `any` | n/a | yes |
| <a name="input_storage_quota"></a> [storage\_quota](#input\_storage\_quota) | storage quota in GB, must be a number | `number` | `100` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_esg_frontend_url"></a> [esg\_frontend\_url](#output\_esg\_frontend\_url) | n/a |
| <a name="output_rabbitmq_name"></a> [rabbitmq\_name](#output\_rabbitmq\_name) | n/a |
<!-- END_TF_DOCS -->