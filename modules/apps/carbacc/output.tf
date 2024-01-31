output "carbacc_frontend_url" {
  value = "https://${jsondecode(azapi_resource.carbacc_frontend_service.output).properties.configuration.ingress.fqdn}"
}

output "carbon_api_url" {
  value = "https://${jsondecode(azapi_resource.carbacc_taskmanagement_service.output).properties.configuration.ingress.fqdn}"
}