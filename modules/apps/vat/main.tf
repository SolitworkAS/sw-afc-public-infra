
# define locals
locals {
  # Vat processor configuration
  vat_processor_name          = "vat-processor"
  vat_processor_image         = "${var.container_registry}/images/vat/processor:${var.vat_version}"
  
  # Vat datamanager configuration
  vat_datamanager_name        = "vatapi"
  vat_datamanager_image       = "${var.container_registry}/images/vat/datamanager:${var.vat_version}"
  attachments_mount_path      = "/mnt/vatfiles"
  vat_datamanager_init_image  = "${var.container_registry}/images/vat/datamanager-init:${var.vat_version}"

  # Vat frontend configuration
  vat_frontend_name           = "vat"
  vat_frontend_image          = "${var.container_registry}/images/vat/frontend:${var.vat_version}"

  # Queue configuration
  rabbitmq_name               = "rabbitmq"
  config_queue                = "vat-config-queue"
  config_request_queue        = "vat-config-request-queue"
  transaction_queue           = "vat-fintransaction-queue"
  transaction_processed_queue = "vat-vattransaction-queue"
  queue_chunk_size            = "10000"
  config_timeout_minutes      = "5"
}

# Create the vat-db database
resource "azurerm_postgresql_flexible_server_database" "vatdb" {
  server_id                   = var.database_server_id
  name                        = var.database_database
  collation                   = "en_US.utf8"
  charset                     = "UTF8"
}

# Create a file share
resource "azurerm_storage_share" "vatshare" {
  name                        = "vatshare"
  storage_account_name        = var.storage_account_name_vat
  quota                       = var.storage_quota
  access_tier                 = var.storage_access_tier
  lifecycle { 
  prevent_destroy = true
  }
}

resource "azurerm_container_app_environment_storage" "vatfiles" {
  name                         = "vatfiles"
  container_app_environment_id = var.container_app_environment_id
  account_name                 = var.storage_account_name_vat
  share_name                   = azurerm_storage_share.vatshare.name
  access_key                   = var.storage_primary_access_key_vat
  access_mode                  = "ReadWrite"
  lifecycle { 
  prevent_destroy = true
  }
  depends_on                   = [ azurerm_storage_share.vatshare]
}

resource "azurerm_backup_protected_file_share" "vatprotectedfileshare" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name
  source_file_share_name = azurerm_storage_share.vatshare.name
  source_storage_account_id = var.source_storage_account_id
  backup_policy_id = var.backup_policy_id
  depends_on = [ azurerm_container_app_environment_storage.vatfiles, azurerm_storage_share.vatshare]
}

# Create a container app for the VAT processor
resource "azurerm_container_app" "vat_processor" {
  name = local.vat_processor_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name = var.resource_group_name
  revision_mode = "Single"
  secret {
    name = "rabbitmqpassword"
    value = var.rabbitmq_password
  }
  secret {
    name = "containerregistrypassword"
    value = var.container_registry_password
  }
  template {
    container {
      name = "vat-processor"
      image = local.vat_processor_image 
      cpu = 0.25
      memory = "0.5Gi"
      env {
        name = "LOGLEVEL"
        value = "INFO"
      }
      env {
        name = "RABBITMQ_HOST"
        value = var.rabbitmq_name
      }
      env {
        name = "RABBITMQ_PORT"
        value = "5672"
      }
      env {
        name = "RABBITMQ_VHOST"
        value = var.customer
      }
      env {
        name = "RABBITMQ_USER"
        value = var.rabbitmq_user
      }
      env {
        name = "RABBITMQ_PASS"
        secret_name = "rabbitmqpassword"
      }
      env {
        name = "CONFIG_QUEUE"
        value = local.config_queue
      }
      env {
        name = "CONFIG_REQUEST_QUEUE"
        value = local.config_request_queue
      }
      env {
        name = "TRANSACTION_QUEUE"
        value = local.transaction_queue
      }
      env {
        name = "TRANSACTION_PROCESSED_QUEUE"
        value = local.transaction_processed_queue
      }
      env {
        name = "QUEUE_CHUNK_SIZE"
        value = local.queue_chunk_size
      }
      env {
        name = "CONFIG_TIMEOUT_MINUTES"
        value = local.config_timeout_minutes
      }
    }
    min_replicas = 1
    max_replicas = 1
  }
  registry {
    server = var.container_registry
    username = var.container_registry_username
    password_secret_name = "containerregistrypassword"
  }

}

resource "azapi_resource" "vat_datamanager" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.vat_datamanager_name
  parent_id = var.resource_group_id
  location = var.location
  body = jsonencode({
    properties = {
      configuration = {
        secrets = [
          {
            name = "rabbitmqpassword"
            value = var.rabbitmq_password
          },
          {
            name = "databasepassword"
            value = var.database_password
          },
          {
            name = "containerregistrypassword"
            value = var.container_registry_password
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
          targetPort = 8011
          traffic = [
            {
              latestRevision = true
              weight = 100
            }
          ]
        }
        activeRevisionsMode = "Single"
      }
      environmentId = var.container_app_environment_id
      template = {
        containers = [
          {
            name = "vat-datamanager2"
            image = local.vat_datamanager_image
            resources = {
              cpu = 1
              memory = "2Gi"
            }
            env = [
              {
                name = "DATAMANAGER_VERSION"
                value = var.vat_version
              },
              {
                name = "LOGLEVEL"
                value = "INFO"
              },
              {
                name = "POSTGRES_SERVER"
                value = var.database_server_url
              },
              {
                name = "POSTGRES_DB"
                value = var.database_database
              },
              {
                name = "POSTGRES_SCHEMA"
                value = "datamanager"
              },
              {
                name = "POSTGRES_USER"
                value = var.database_user
              },
              {
                name = "POSTGRES_PASSWORD"
                secretRef = "databasepassword"
              },
              {
                name = "RABBITMQ_HOST"
                value = var.rabbitmq_name
              },
              {
                name = "RABBITMQ_PORT"
                value = "5672"
              },
              {
                name = "RABBITMQ_VHOST"
                value = var.customer
              },
              {
                name = "RABBITMQ_USER"
                value = var.rabbitmq_user
              },
              {
                name = "RABBITMQ_PASS"
                secretRef = "rabbitmqpassword"
              },
              {
                name = "CONFIG_QUEUE"
                value = local.config_queue
              },
              {
                name = "CONFIG_REQUEST_QUEUE"
                value = local.config_request_queue
              },
              {
                name = "TRANSACTION_QUEUE"
                value = local.transaction_queue
              },
              {
                name = "TRANSACTION_PROCESSED_QUEUE"
                value = local.transaction_processed_queue
              },
              {
                name = "QUEUE_CHUNK_SIZE"
                value = local.queue_chunk_size
              },
              {
                name = "CONFIG_TIMEOUT_MINUTES"
                value = local.config_timeout_minutes
              },
              {
                name = "KEYCLOAK_URL"
                value = var.keycloak_url
              },
              {
                name = "KEYCLOAK_REALM"
                value = var.keycloak_realm
              },
              {
                name = "KEYCLOAK_CLIENT_ID"
                value = var.keycloak_client_id
              },
              {
                name = "ATTACHMENTS_PATH"
                value = local.attachments_mount_path
              }
            ]
            volumeMounts = [
              {
                volumeName = "vatfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "vatfiles"
            storageName = azurerm_container_app_environment_storage.vatfiles.name
            storageType = "AzureFile"
          }
        
        ]
        scale = {
          minReplicas = var.min_replicas
          maxReplicas = var.max_replicas
        }
        initContainers = [
          {
            name = "vat-datamanager-init"
            image = local.vat_datamanager_init_image
            resources = {
              cpu = 0.25
              memory = "0.5Gi"
            }
            env = [
              {
                name = "POSTGRES_SERVER"
                value = var.database_server_url
              },
              {
                name = "POSTGRES_DB"
                value = var.database_database
              },
              {
                name = "POSTGRES_SCHEMA"
                value = "datamanager"
              },
              {
                name = "POSTGRES_USER"
                value = var.database_user
              },
              {
                name = "POSTGRES_PASSWORD"
                secretRef = "databasepassword"
              }
            ]
          }
        ]
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
  depends_on = [  azurerm_container_app_environment_storage.vatfiles,
                  azurerm_postgresql_flexible_server_database.vatdb
               ]
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "datamanager-postgres-fw" {
  name             = "datamanager-postgres-fw"
  server_id        = var.database_server_id
  start_ip_address = jsondecode(azapi_resource.vat_datamanager.output).properties.outboundIpAddresses.0
  end_ip_address   = jsondecode(azapi_resource.vat_datamanager.output).properties.outboundIpAddresses.0
  depends_on = [azapi_resource.vat_datamanager]
}

# Create a container app for the VAT frontend
resource "azurerm_container_app" "vat_frontend" {
  name = local.vat_frontend_name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name = var.resource_group_name
  revision_mode = "Single"
  secret {
    name = "containerregistrypassword"
    value = var.container_registry_password
  }
  template {
    container {
      name = local.vat_frontend_name
      image = local.vat_frontend_image
      cpu = 0.25
      memory = "0.5Gi"
      env {
        name = "VAT_BACKEND_URL"
        value = "https://${jsondecode(azapi_resource.vat_datamanager.output).properties.configuration.ingress.fqdn}"
      }
      env {
        name = "KEYCLOAK_URL"
        value = var.keycloak_url
      }
      env {
        name = "KEYCLOAK_REALM"
        value = var.keycloak_realm
      }
      env {
        name = "KEYCLOAK_CLIENT_ID"
        value = var.keycloak_client_id
      }
    }
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas
  }
  registry {
    server = var.container_registry
    username = var.container_registry_username
    password_secret_name = "containerregistrypassword"
  }
  ingress {
    external_enabled = true
    target_port = 80
    traffic_weight {
      latest_revision = true
      percentage = 100
    }
  }
  depends_on = [azapi_resource.vat_datamanager]
}
