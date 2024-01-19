<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.1.0 |
| <a name="requirement_keycloak"></a> [keycloak](#requirement\_keycloak) | >= 4.3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_keycloak"></a> [keycloak](#provider\_keycloak) | >= 4.3.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [keycloak_authentication_execution.execution_four](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.execution_one](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.execution_three](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_execution.execution_two](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/authentication_execution) | resource |
| [keycloak_authentication_flow.oidc_flow](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/authentication_flow) | resource |
| [keycloak_group.admin_group](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.carbon_group](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.default_group](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.esg_organizer_group](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.esg_respondent_group](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group.reporting_group](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group_roles.admin_group_roles](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_group_roles.carbon_group_roles](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_group_roles.default_group_roles](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_group_roles.esg_organizer_group_roles](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_group_roles.esg_respondent_group_roles](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_group_roles.reporting_group_roles](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_openid_audience_protocol_mapper.carbacc_audience_mapper](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_audience_protocol_mapper) | resource |
| [keycloak_openid_audience_protocol_mapper.esg_audience_mapper](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_audience_protocol_mapper) | resource |
| [keycloak_openid_audience_protocol_mapper.vat_audience_mapper](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_audience_protocol_mapper) | resource |
| [keycloak_openid_client.carbacc](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_client.esg](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_client.vat](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client) | resource |
| [keycloak_openid_client_default_scopes.carbacc_default_scopes_mapper](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client_default_scopes) | resource |
| [keycloak_openid_client_default_scopes.esg_default_scopes_mapper](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client_default_scopes) | resource |
| [keycloak_openid_client_default_scopes.vat_default_scopes_mapper](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client_default_scopes) | resource |
| [keycloak_openid_client_scope.client_scopes](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client_scope) | resource |
| [keycloak_realm.realm](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/realm) | resource |
| [keycloak_role.admin_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/role) | resource |
| [keycloak_role.carbon_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/role) | resource |
| [keycloak_role.organizer_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/role) | resource |
| [keycloak_role.reporting_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/role) | resource |
| [keycloak_role.respondent_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/role) | resource |
| [keycloak_user.user_with_initial_password](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/user) | resource |
| [keycloak_user_groups.user_groups](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/user_groups) | resource |
| [keycloak_openid_client.account](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/data-sources/openid_client) | data source |
| [keycloak_openid_client.realm_management](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/data-sources/openid_client) | data source |
| [keycloak_role.manage-users_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/data-sources/role) | data source |
| [keycloak_role.manage_account_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/data-sources/role) | data source |
| [keycloak_role.view-users_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/data-sources/role) | data source |
| [keycloak_role.view_profile_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/data-sources/role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_admin_email"></a> [app\_admin\_email](#input\_app\_admin\_email) | Application admin email, must be a valid email address | `any` | n/a | yes |
| <a name="input_app_admin_first_name"></a> [app\_admin\_first\_name](#input\_app\_admin\_first\_name) | Application admin first name | `any` | n/a | yes |
| <a name="input_app_admin_initial_password"></a> [app\_admin\_initial\_password](#input\_app\_admin\_initial\_password) | Application admin initial password, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_app_admin_last_name"></a> [app\_admin\_last\_name](#input\_app\_admin\_last\_name) | Application admin last name | `any` | n/a | yes |
| <a name="input_carbacc_frontend_url"></a> [carbacc\_frontend\_url](#input\_carbacc\_frontend\_url) | ESG frontend URL | `any` | n/a | yes |
| <a name="input_email_theme"></a> [email\_theme](#input\_email\_theme) | Keycloak email theme | `string` | `"solitwork"` | no |
| <a name="input_esg_frontend_url"></a> [esg\_frontend\_url](#input\_esg\_frontend\_url) | ESG frontend URL | `any` | n/a | yes |
| <a name="input_keycloak_admin_password"></a> [keycloak\_admin\_password](#input\_keycloak\_admin\_password) | password for Keycloak admin user, must be at least 8 characters long | `any` | n/a | yes |
| <a name="input_keycloak_admin_user"></a> [keycloak\_admin\_user](#input\_keycloak\_admin\_user) | Keycloak admin user, must only contain lowercase letters and numbers | `string` | `"admin"` | no |
| <a name="input_keycloak_url"></a> [keycloak\_url](#input\_keycloak\_url) | keycloak url | `any` | n/a | yes |
| <a name="input_login_theme"></a> [login\_theme](#input\_login\_theme) | Keycloak login theme | `string` | `"solitwork"` | no |
| <a name="input_realm_name"></a> [realm\_name](#input\_realm\_name) | Realm name, must only contain lowercase letters and numbers | `any` | n/a | yes |
| <a name="input_smtp_from"></a> [smtp\_from](#input\_smtp\_from) | SMTP from address, must be a valid email address | `any` | n/a | yes |
| <a name="input_smtp_host"></a> [smtp\_host](#input\_smtp\_host) | SMTP host | `any` | n/a | yes |
| <a name="input_smtp_password"></a> [smtp\_password](#input\_smtp\_password) | SMTP password | `any` | n/a | yes |
| <a name="input_smtp_port"></a> [smtp\_port](#input\_smtp\_port) | SMTP port, must be a number | `any` | n/a | yes |
| <a name="input_smtp_username"></a> [smtp\_username](#input\_smtp\_username) | SMTP username | `any` | n/a | yes |
| <a name="input_vat_frontend_url"></a> [vat\_frontend\_url](#input\_vat\_frontend\_url) | VAT frontend URL, must be a valid URL or empty string | `any` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->