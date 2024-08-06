module "main" {
  source = "./modules/main"

  customer = var.customer

  rabbitmq_password       = var.rabbitmq_password
  keycloak_admin_password = var.keycloak_admin_password
  database_password       = var.database_password
  reportingpassword       = var.reportingpassword
  availability_zone       = var.availability_zone

  smtp_from     = var.smtp_from
  smtp_host     = var.smtp_host
  smtp_port     = var.smtp_port
  smtp_username = var.smtp_username
  smtp_password = var.smtp_password

  container_registry          = var.container_registry
  container_registry_username = var.container_registry_username
  container_registry_password = var.container_registry_password

  min_cpu = var.min_cpu
  min_memory = var.min_memory

  app_admin_email            = var.app_admin_email
  app_admin_first_name       = var.app_admin_first_name
  app_admin_last_name        = var.app_admin_last_name
  app_admin_initial_password = var.app_admin_initial_password
  storage_access_tier = var.storage_access_tier
  storage_quota = var.storage_quota


  location         = var.location
  database_sku     = var.database_sku
  database_storage = var.database_storage

  carbacc_version = var.carbacc_version
  esg_version     = var.esg_version
  vat_version     = var.vat_version
  keycloak_version = var.keycloak_version
  audit_version = var.audit_version

  min_replicas = var.min_replicas
  max_replicas = var.max_replicas

  include_vat     = var.include_vat
  include_esg     = var.include_esg
  include_carbacc = var.include_carbacc

  use_proxy = var.use_proxy
  proxy_domain = var.proxy_domain

}