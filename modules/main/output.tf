output "env_domain" {
  value = module.environment.default_domain
}
output "carbon_api_url" {
  value = var.include_esg ? module.carbacc[0].carbon_api_url : ""
}
output "esg_frontend_url" {
  value = var.include_esg ? module.esg[0].esg_frontend_url : ""
}
output "esg_organization_api" {
  value = var.include_esg ? module.esg[0].esg_organization_api : ""
}
output "esg_reporting_api" {
  value = var.include_esg ? module.esg[0].esg_reporting_api : ""
}
output "vat_frontend_url" {
  value = var.include_vat ? module.vat[0].vat_frontend_url : ""
}
output "user_management_url" {
  value = module.environment.keycloak_url
}
output "vat_api_url" {
  value = var.include_vat ? module.vat[0].vat_api_url : ""
}
output "sas_token" {
  value = nonsensitive(var.include_esg ? module.esg[0].sas_token : "")
}

output "pbi_container_url" {
  value = var.include_esg ? module.esg[0].pbi_container_url : ""
}