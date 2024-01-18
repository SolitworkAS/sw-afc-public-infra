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
| [azapi_resource.keycloak](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.rabbitmq](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azurerm_backup_policy_file_share.swsharebackuppolicy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_policy_file_share) | resource |
| [azurerm_container_app_environment.sw-aca](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app_environment) | resource |
| [azurerm_log_analytics_workspace.sw-log-analytics-workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_postgresql_flexible_server.postgres](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_configuration.PG_TRGM_extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_configuration) | resource |
| [azurerm_postgresql_flexible_server_database.keycloakdb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule.keycloak-postgres-fw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) | resource |
| [azurerm_recovery_services_vault.swsharebackupvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.storage](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_registry"></a> [container\_registry](#input\_container\_registry) | container registry url | `any` | n/a | yes |
| <a name="input_container_registry_password"></a> [container\_registry\_password](#input\_container\_registry\_password) | container registry password, must not be empty | `any` | n/a | yes |
| <a name="input_container_registry_username"></a> [container\_registry\_username](#input\_container\_registry\_username) | container registry username, must not be empty | `any` | n/a | yes |
| <a name="input_customer"></a> [customer](#input\_customer) | shorthand abbrieviation for customer name, must only contain lowercase letters and numbers | `any` | n/a | yes |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | database admin password, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_database_sku"></a> [database\_sku](#input\_database\_sku) | database sku, must be a valid Azure database sku | `string` | `"B_Standard_B2s"` | no |
| <a name="input_database_storage"></a> [database\_storage](#input\_database\_storage) | database storage in MB, must be a valid Azure database storage size | `any` | n/a | yes |
| <a name="input_database_user"></a> [database\_user](#input\_database\_user) | database admin user, must only contain lowercase letters and numbers | `any` | n/a | yes |
| <a name="input_keycloak_admin_password"></a> [keycloak\_admin\_password](#input\_keycloak\_admin\_password) | password for Keycloak admin user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_keycloak_admin_user"></a> [keycloak\_admin\_user](#input\_keycloak\_admin\_user) | Keycloak admin user, must only contain lowercase letters and numbers | `any` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | location of the resource group, must be a valid Azure location | `any` | n/a | yes |
| <a name="input_rabbitmq_image"></a> [rabbitmq\_image](#input\_rabbitmq\_image) | docker image for rabbitmq | `string` | `"rabbitmq:3.12.6"` | no |
| <a name="input_rabbitmq_password"></a> [rabbitmq\_password](#input\_rabbitmq\_password) | password for RabbitMQ default user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_rabbitmq_user"></a> [rabbitmq\_user](#input\_rabbitmq\_user) | RabbitMQ default user, must only contain lowercase letters and numbers | `any` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | name of the resource group, must only contain lowercase letters, numbers and dashes | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_id"></a> [container\_app\_environment\_id](#output\_container\_app\_environment\_id) | n/a |
| <a name="output_database_server_id"></a> [database\_server\_id](#output\_database\_server\_id) | n/a |
| <a name="output_database_server_url"></a> [database\_server\_url](#output\_database\_server\_url) | n/a |
| <a name="output_keycloak_url"></a> [keycloak\_url](#output\_keycloak\_url) | n/a |
| <a name="output_rabbitmq_name"></a> [rabbitmq\_name](#output\_rabbitmq\_name) | n/a |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | n/a |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | n/a |
| <a name="output_storage_primary_access_key"></a> [storage\_primary\_access\_key](#output\_storage\_primary\_access\_key) | n/a |
<!-- END_TF_DOCS -->