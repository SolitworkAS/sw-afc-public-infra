output "carbacc_frontend_url" {
  value = var.include_carbacc ? module.carbacc[0].carbacc_frontend_url : ""
}
output "esg_frontend_url" {
  value = var.include_esg ? module.esg[0].esg_frontend_url : ""
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