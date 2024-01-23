
output "vat_api_url" {
  value = "https://${jsondecode(azapi_resource.vat_datamanager.output).properties.configuration.ingress.fqdn}"
}

output "vat_frontend_url" {
  value = "https://${azurerm_container_app.vat_frontend.ingress.0.fqdn}"
}