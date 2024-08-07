locals {
  keycloak_url = module.environment.keycloak_url
  resource_group_name = "rg-afc-ng-${var.customer}"
  tfstate = "${var.customer}/terraform.tfstate"
}

module "environment" {
  source                      = "../environment"
  customer                    = var.customer
  resource_group_name        = local.resource_group_name
  location                    = var.location
  container_registry          = var.container_registry
  container_registry_username = var.container_registry_username
  container_registry_password = var.container_registry_password
  min_cpu = var.min_cpu
  min_memory = var.min_memory
  database_sku                = var.database_sku
  database_storage            = var.database_storage
  database_user               = var.database_user
  database_password           = var.database_password
  keycloak_admin_user         = var.keycloak_admin_user
  keycloak_admin_password     = var.keycloak_admin_password
  rabbitmq_password           = var.rabbitmq_password
  rabbitmq_user               = var.rabbitmq_user
  availability_zone = var.availability_zone
  keycloak_version = var.keycloak_version
  audit_version = var.audit_version
}

module "carbacc" {
  count = var.include_carbacc ? 1 : 0
  source              = "../apps/carbacc"
  customer            = var.customer
  carbacc_version     = var.carbacc_version
  location            = var.location
  resource_group_name = local.resource_group_name
  resource_group_id   = module.environment.resource_group_id
  

  container_app_environment_id = module.environment.container_app_environment_id


  min_replicas = var.min_replicas
  max_replicas = var.max_replicas
  min_cpu = var.min_cpu
  min_memory = var.min_memory

  container_registry          = var.container_registry
  container_registry_username = var.container_registry_username
  container_registry_password = var.container_registry_password

  storage_account_name_carbacc       = module.environment.storage_account_name
  storage_access_tier = var.storage_access_tier
  storage_quota = var.storage_quota
  storage_primary_access_key_carbacc = module.environment.storage_primary_access_key
  backup_policy_id = module.environment.backup_policy_id
  storage_account_id = module.environment.storage_account_id
  recovery_vault_name = module.environment.recovery_vault_name
  source_storage_account_id = module.environment.source_storage_account_id

  rabbitmq_image    = var.rabbitmq_image
  rabbitmq_user     = var.rabbitmq_user
  rabbitmq_password = var.rabbitmq_password

  database_server_url = module.environment.database_server_url
  database_server_id  = module.environment.database_server_id
  database_user       = var.database_user
  database_password   = var.database_password
  rabbitmq_name       = module.environment.rabbitmq_name

  keycloak_realm = var.customer
  keycloak_url = module.environment.keycloak_url
  reportingpassword = var.reportingpassword
  default_domain = module.environment.default_domain
  esg_url = var.use_proxy? "https://${var.customer}.${var.proxy_domain}" : "https://esg-frontend-service.${module.environment.default_domain}"

  depends_on = [module.environment]

}

module "esg" {
  count = var.include_esg ? 1 : 0
  source              = "../apps/esg"
  customer            = var.customer
  esg_version         = var.esg_version
  location            = var.location
  resource_group_name = local.resource_group_name
  resource_group_id   = module.environment.resource_group_id

  container_app_environment_id = module.environment.container_app_environment_id

  min_replicas = var.min_replicas
  max_replicas = var.max_replicas

  container_registry          = var.container_registry
  container_registry_username = var.container_registry_username
  container_registry_password = var.container_registry_password

  storage_account_name_esg       = module.environment.storage_account_name
  storage_primary_access_key_esg = module.environment.storage_primary_access_key
  storage_access_tier = var.storage_access_tier
  storage_quota = var.storage_quota
  backup_policy_id = module.environment.backup_policy_id
  storage_account_id = module.environment.storage_account_id
  recovery_vault_name = module.environment.recovery_vault_name
  source_storage_account_id = module.environment.source_storage_account_id

  rabbitmq_image    = var.rabbitmq_image
  rabbitmq_user     = var.rabbitmq_user
  rabbitmq_password = var.rabbitmq_password

  database_server_url = module.environment.database_server_url
  database_server_id  = module.environment.database_server_id
  database_user       = var.database_user
  database_password   = var.database_password
  reportingpassword   = var.reportingpassword
  rabbitmq_host       = module.environment.rabbitmq_name
  min_cpu = var.min_cpu
  min_memory = var.min_memory

  keycloak_realm = var.customer
  keycloak_url = module.environment.keycloak_url
  default_domain = module.environment.default_domain
  carbacc_frontend_url = var.include_carbacc ? var.use_proxy? "https://${var.customer}.${var.proxy_domain}/carbacc" : "https://carbacc-frontend-service.${module.environment.default_domain}" : ""

  smtp_host     = var.smtp_host
  smtp_port     = var.smtp_port
  smtp_username = var.smtp_username
  smtp_password = var.smtp_password
  smtp_from     = var.smtp_from

  carbacc_included = var.include_carbacc
  env_domain =  module.environment.default_domain

  depends_on = [module.environment]
}

module "vat" {
  count = var.include_vat ? 1 : 0
  source              = "../apps/vat"
  customer            = var.customer
  vat_version         = var.vat_version
  location            = var.location
  resource_group_name = local.resource_group_name
  resource_group_id   = module.environment.resource_group_id

  container_app_environment_id = module.environment.container_app_environment_id


  min_replicas = var.min_replicas
  max_replicas = var.max_replicas

  container_registry          = var.container_registry
  container_registry_username = var.container_registry_username
  container_registry_password = var.container_registry_password

  storage_account_name_vat       = module.environment.storage_account_name
  storage_primary_access_key_vat = module.environment.storage_primary_access_key
  storage_access_tier = var.storage_access_tier
  storage_quota = var.storage_quota
  backup_policy_id = module.environment.backup_policy_id
  storage_account_id = module.environment.storage_account_id
  recovery_vault_name = module.environment.recovery_vault_name
  source_storage_account_id = module.environment.source_storage_account_id

  rabbitmq_image    = var.rabbitmq_image
  rabbitmq_user     = var.rabbitmq_user
  rabbitmq_password = var.rabbitmq_password
  rabbitmq_name     = module.environment.rabbitmq_name

  database_server_url = module.environment.database_server_url
  database_server_id  = module.environment.database_server_id
  database_user       = var.database_user
  database_password   = var.database_password

  keycloak_realm = var.customer
  keycloak_url = module.environment.keycloak_url

  depends_on = [module.environment]
}

resource "time_sleep" "Deployment_Proceed" {
  depends_on = [module.environment]
  create_duration = "300s"
}

module "realm" {
  source = "../realm"

  realm_name = var.customer
  default_domain = module.environment.default_domain
  smtp_host     = var.smtp_host
  smtp_port     = var.smtp_port
  smtp_username = var.smtp_username
  smtp_password = var.smtp_password
  smtp_from     = var.smtp_from

  carbacc_frontend_url = var.include_carbacc ? module.carbacc[0].carbacc_frontend_url : ""
  esg_frontend_url     = var.include_esg ? module.esg[0].esg_frontend_url : ""
  vat_frontend_url = var.include_vat ? module.vat[0].vat_frontend_url : ""

  login_theme = "sw-custom-theme"
  email_theme = "keycloak"

  app_admin_email            = var.app_admin_email
  app_admin_initial_password = var.app_admin_initial_password
  app_admin_first_name       = var.app_admin_first_name
  app_admin_last_name        = var.app_admin_last_name
  keycloak_url               = module.environment.keycloak_url
  keycloak_admin_password    = var.keycloak_admin_password
  keycloak_admin_user        = var.keycloak_admin_user
  reportingpassword = var.reportingpassword

  depends_on = [time_sleep.Deployment_Proceed]

}


