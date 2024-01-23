output "esg_frontend_url" {
  value = "https://${jsondecode(azapi_resource.esg_frontend_service.output).properties.configuration.ingress.fqdn}"
}
output "rabbitmq_name" {
  value = var.rabbitmq_host
}