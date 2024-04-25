
# define locals
locals {

  storage                  = "${var.customer}swstorage"

  # Database configuration
  swdbserver                 = "${var.customer}-sw-db-server"
  
  # Keycloak configuration
  keycloak_name               = "keycloak"
  keycloakdb                  = "keycloak"
  keycloak_realm              = "customera"
  keycloak_client_id          = "afc-carbacc"
  keycloak_client_id_esg          = "afc-esg"
  keycloak_client_id_vat          = "afc-vat"
  keycloak_image = "${var.container_registry}/images/environment/keycloak:${var.keycloak_version}"

  # Queue configuration
  rabbitmq_name               = "rabbitmq"
  config_queue                = "vat-config-queue"
  config_request_queue        = "vat-config-request-queue"
  transaction_queue           = "vat-fintransaction-queue"
  transaction_processed_queue = "vat-vattransaction-queue"
  queue_chunk_size            = "10000"
  config_timeout_minutes      = "5"
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name                        = var.resource_group_name
  location                    = var.location
  tags = {
    "Managed_By" = "Terraform-Cloud"
  }
}

# Create a PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                        = local.swdbserver
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  version                     = "15"
  administrator_login         = var.database_user
  administrator_password      = var.database_password
  zone                        = var.availability_zone
  backup_retention_days       = 30
  storage_mb                  = var.database_storage
  sku_name                    = var.database_sku
  lifecycle { 
  prevent_destroy = true
  }
  depends_on                  = [azurerm_resource_group.rg]
}

resource "azurerm_postgresql_flexible_server_configuration" "PG_TRGM_extension" {
  name      = "azure.extensions"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = "PG_TRGM"
}
# Create a storage account
resource "azurerm_storage_account" "storage" {
  name                        = local.storage
  resource_group_name         = azurerm_resource_group.rg.name
  location                    = azurerm_resource_group.rg.location
  account_tier                = "Standard"
  account_replication_type    = "GRS"
  access_tier                 = "Hot"
  share_properties {
    retention_policy {
      days = 30
    }
  }
  lifecycle { 
  prevent_destroy = true
  }
  depends_on = [azurerm_resource_group.rg]
}

# Create a vault for backups
resource "azurerm_recovery_services_vault" "swsharebackupvault" {
  name                        = "swsharebackupvault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  sku                         = "Standard"
  depends_on                  = [azurerm_resource_group.rg]
  lifecycle { 
  prevent_destroy = true
  }
}

# Create a backup policy
resource "azurerm_backup_policy_file_share" "swsharebackuppolicy" {
  name                        = "swsharebackuppolicy"
  resource_group_name         = azurerm_resource_group.rg.name
  recovery_vault_name         = azurerm_recovery_services_vault.swsharebackupvault.name
  timezone                    = "UTC"
  backup {
    frequency                 = "Daily"
    time                      = "23:00"
  }

  retention_daily {
    count                     = 30
  }
  lifecycle { 
  prevent_destroy = true
  }
  depends_on                  = [azurerm_resource_group.rg, azurerm_recovery_services_vault.swsharebackupvault]
}

resource "azurerm_backup_container_storage_account" "sw-protection-container" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.swsharebackupvault.name
  storage_account_id  = azurerm_storage_account.storage.id
}

# Create the log analytics workspace
resource "azurerm_log_analytics_workspace" "sw-log-analytics-workspace" {
  name                        = "sw-log-analytics-workspace"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  # sku                         = "Free"
  retention_in_days           = 30
  depends_on                  = [azurerm_resource_group.rg]
}

# Create the Azure Container App environment
resource "azurerm_container_app_environment" "sw-aca" {
  name                        = "sw-aca"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  log_analytics_workspace_id  = azurerm_log_analytics_workspace.sw-log-analytics-workspace.id
  depends_on                  = [azurerm_resource_group.rg, azurerm_log_analytics_workspace.sw-log-analytics-workspace]
}

##### KEYCLOACK resources #####
# create the keycloak database
resource "azurerm_postgresql_flexible_server_database" "keycloakdb" {
  server_id                   = azurerm_postgresql_flexible_server.postgres.id
  name                        = local.keycloakdb
  collation                   = "en_US.utf8"
  charset                     = "UTF8"
  lifecycle { 
  prevent_destroy = true
  }
  depends_on                  = [azurerm_resource_group.rg, azurerm_postgresql_flexible_server.postgres]
}


resource "azapi_resource" "keycloak" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.keycloak_name
  location = var.location
  parent_id = azurerm_resource_group.rg.id
  body = jsonencode({
    properties = {
      configuration = {
        secrets = [
      {
      name = "keycloakpassword"
      value = var.keycloak_admin_password
      },
      {
        name = "keycloakdbpassword"
        value = var.database_password
      },
      {
        name = "containerregistrypassword"
        value = var.container_registry_password
      }
        ]
        registries = [
          {
            server = var.container_registry
            username = var.container_registry_username
            passwordSecretRef = "containerregistrypassword"
          }
        ]
        ingress = {
          external = true
          targetPort = 8080
          traffic = [
            {
              latestRevision = true
              weight = 100
            }
          ]
        }
        activeRevisionsMode = "Single"
      }
      environmentId = azurerm_container_app_environment.sw-aca.id
      template = {
        containers = [
          {
            name = "keycloak"
            image = local.keycloak_image
            resources = {
                cpu = 0.5
                memory = "1Gi"
            }
            env = [
              {
        name = "KC_DB_URL_HOST"
        value = azurerm_postgresql_flexible_server.postgres.fqdn
      },
      {
        name = "KC_DB_URL_PORT"
        value = "5432"
      },
      {
        name = "KC_DB_URL_DATABASE"
        value = local.keycloakdb
      },
      {
        name = "KC_DB_USERNAME"
        value = var.database_user
      },
      {
        name = "KC_DB_PASSWORD"
        secretRef = "keycloakdbpassword"
      },
      {
        name = "KC_DB_SCHEMA"
        value = "public"
      },
      {
        name = "KEYCLOAK_ADMIN"
        value = var.keycloak_admin_user
      },
      {
        name = "KEYCLOAK_ADMIN_PASSWORD"
        secretRef = "keycloakpassword"
      }
            ]
          }
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 1
        }
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
   depends_on = [azurerm_resource_group.rg, azurerm_container_app_environment.sw-aca, azurerm_postgresql_flexible_server_database.keycloakdb]

}

resource "azapi_resource" "rabbitmq" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.rabbitmq_name
  location = var.location
  parent_id = azurerm_resource_group.rg.id
  body = jsonencode({
    properties = {
      configuration = {
        secrets = [
       {
        name = "rabbitmqpassword"
        value = var.rabbitmq_password
       }
        ]
        ingress = {
          external = false
          targetPort = 5672
          traffic = [
            {
              latestRevision = true
              weight = 100
            }
          ]
          transport = "tcp"
        }
        activeRevisionsMode = "Single"
      }
      environmentId = azurerm_container_app_environment.sw-aca.id
      template = {
        containers = [
          {
            name = "rabbitmq"
            image = var.rabbitmq_image
            resources = {
                cpu = 0.5
                memory = "1Gi"
            }
            env = [
              {
                name  = "RABBITMQ_DEFAULT_USER"
                value = var.rabbitmq_user
              },
              {
                name  = "RABBITMQ_DEFAULT_PASS"
                secretRef = "rabbitmqpassword"
              },
              {
                name  = "RABBITMQ_DEFAULT_VHOST"
                value = var.customer
              }
        
            ]
          }
        ]
        scale = {
          minReplicas = 1
          maxReplicas = 1
        }
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
   depends_on = [azurerm_resource_group.rg, azurerm_container_app_environment.sw-aca, azurerm_postgresql_flexible_server_database.keycloakdb]

}

# Create a firewall rule for the keycloak container app
resource "azurerm_postgresql_flexible_server_firewall_rule" "keycloak-postgres-fw" {
  name             = "keycloak-postgres-fw"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "${jsondecode(azapi_resource.keycloak.output).properties.outboundIpAddresses[0]}"
  end_ip_address   = "${jsondecode(azapi_resource.keycloak.output).properties.outboundIpAddresses[0]}"
  depends_on = [azurerm_postgresql_flexible_server.postgres, azapi_resource.keycloak]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "solitwork-postgres-fw" {
  name             = "solitwork-postgres-fw"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "152.115.169.50"
  end_ip_address   = "152.115.169.50"
  depends_on = [azurerm_postgresql_flexible_server.postgres]
}

