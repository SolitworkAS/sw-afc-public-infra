output "esg_frontend_url" {
  value = module.main.esg_frontend_url
}
output "vat_frontend_url" {
  value = module.main.vat_frontend_url
}
output "keycloak_url" {
  value = module.main.user_management_url
}
output "vat_api_url" {
  value = module.main.vat_api_url
}
output "carbon_api_url" {
  value = module.main.carbon_api_url
}
output "esg_organization_api" {
  value = module.main.esg_organization_api
}
output "esg_reporting_api" {
  value = module.main.esg_reporting_api
}
output "sas_token" {
  value = nonsensitive(module.main.sas_token)
}
output "pbi_container_url" {
  value = module.main.pbi_container_url
}