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