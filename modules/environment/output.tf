output "database_server_url" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

output "database_server_id" {
  value = azurerm_postgresql_flexible_server.postgres.id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

# output "storage_account_name_esg" {
#   value = azurerm_storage_account.esgstorage.name
# }

# output "storage_account_name_vat" {
#   value = azurerm_storage_account.vatstorage.name
# }

output "storage_primary_access_key" {
  value = azurerm_storage_account.storage.primary_access_key
}

# output "storage_primary_access_key_esg" {
#   value = azurerm_storage_account.esgstorage.primary_access_key
# }

# output "storage_primary_access_key_vat" {
#   value = azurerm_storage_account.vatstorage.primary_access_key
# }

output "container_app_environment_id" {
  value = azurerm_container_app_environment.sw-aca.id
}

output "keycloak_url" {
  value = "https://${jsondecode(azapi_resource.keycloak.output).properties.configuration.ingress.fqdn}"
}

output "resource_group_id" {
  value = azurerm_resource_group.rg.id
}
output "rabbitmq_name" {
  value = azapi_resource.rabbitmq.name
}

output "default_domain"{
  value = azurerm_container_app_environment.sw-aca.default_domain
}