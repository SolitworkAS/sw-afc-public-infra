output "esg_frontend_url" {
  value = "https://${jsondecode(azapi_resource.esg_frontend_service.output).properties.configuration.ingress.fqdn}"
}
output "esg_organization_api" {
  value = "https://${jsondecode(azapi_resource.esg_organization_module.output).properties.configuration.ingress.fqdn}"
}
output "esg_reporting_api" {
  value = "https://${jsondecode(azapi_resource.esg_reporting_manager.output).properties.configuration.ingress.fqdn}"
}
output "rabbitmq_name" {
  value = var.rabbitmq_host
}
output "pbi_exporter_access_key" {
  value = nonsensitive(
    substr(data.azurerm_storage_account_sas.pbi_data_access_key.sas, 0, 1) == "?" ?
    substr(data.azurerm_storage_account_sas.pbi_data_access_key.sas, 1, length(data.azurerm_storage_account_sas.pbi_data_access_key.sas) - 1) :
    data.azurerm_storage_account_sas.pbi_data_access_key.sas
  )
  sensitive = false
}


output "pbi_container_url" {
  value = "https://${(azurerm_storage_account.storage.name)}.blob.core.windows.net/${azurerm_storage_container.pbi.name}"
}