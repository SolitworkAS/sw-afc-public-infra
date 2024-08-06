locals {

  carbacc_name          = "carbacc"
  carbacc_souceload_service_name   = "carbacc-sourceload-service"
  carbacc_sourceload_service_image = "${var.container_registry}/images/carbacc/sourceload_service:${var.carbacc_version}"

  # Carbacc taskmanagement configuration
  carbacc_taskmanagement_service_name  = "carbacc-taskmanagement-service"
  carbacc_taskmanagement_service_image = "${var.container_registry}/images/carbacc/taskmanagement_service:${var.carbacc_version}"
  attachments_mount_path               = "/carbacc/files"

  # Carbacc frontend configuration
  carbacc_frontend_name  = "carbacc-frontend-service"
  carbacc_frontend_image = "${var.container_registry}/images/carbacc/frontend_service:${var.carbacc_version}"

}

resource "azurerm_postgresql_flexible_server_database" "carbaccdb" {
  server_id  = var.database_server_id
  name       = var.database_database
  collation  = "en_US.utf8"
  charset    = "UTF8"
}


resource "azurerm_storage_share" "carbaccshare" {
  name                        = "carbaccshare"
  storage_account_name        = var.storage_account_name_carbacc
  quota                       = var.storage_quota
  access_tier                 = var.storage_access_tier
  lifecycle { 
  prevent_destroy = true
  }
}

resource "azurerm_container_app_environment_storage" "carbaccfiles" {
  name                         = "carbaccfiles"
  container_app_environment_id = var.container_app_environment_id
  account_name                 = var.storage_account_name_carbacc
  share_name                   = azurerm_storage_share.carbaccshare.name
  access_key                   = var.storage_primary_access_key_carbacc
  access_mode                  = "ReadWrite"
  lifecycle { 
  prevent_destroy = true
  }
  depends_on                   = [ azurerm_storage_share.carbaccshare]
}

resource "azurerm_backup_protected_file_share" "carbaccprotectedfileshare" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name
  source_file_share_name = azurerm_storage_share.carbaccshare.name
  source_storage_account_id = var.source_storage_account_id
  backup_policy_id = var.backup_policy_id
  depends_on = [ azurerm_container_app_environment_storage.carbaccfiles, azurerm_storage_share.carbaccshare]
}

resource "azapi_resource" "carbacc_frontend_service" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.carbacc_frontend_name
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
          targetPort = 80
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
            name = "carbacc-frontend-service"
            image = local.carbacc_frontend_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
            }
            env = [
      {
        name  = "KEYCLOAK_URL"
        value = var.keycloak_url
      },
      {
        name  = "KEYCLOAK_REALM"
        value = var.keycloak_realm
      },
      {
        name  = "KEYCLOAK_CLIENT_ID"
        value = var.keycloak_client_id
      },
      {
        name = "ESG_URL"
        value = var.esg_url
      },
      {
        name  = "taskManagementUrl"
        value = "https://${jsondecode(azapi_resource.carbacc_taskmanagement_service.output).properties.configuration.ingress.fqdn}"
      },
      {
        name  = "sourceLoadUrl"
        value = "https://${jsondecode(azapi_resource.carbacc_sourceload_service.output).properties.configuration.ingress.fqdn}"
      }
            ]
            volumeMounts = [
              {
                volumeName = "carbaccfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "carbaccfiles"
            storageName = azurerm_container_app_environment_storage.carbaccfiles.name
            storageType = "AzureFile"
          }
        
        ]
        scale = {
          minReplicas = var.min_replicas
          maxReplicas = var.max_replicas
        }
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
  depends_on = [  azurerm_container_app_environment_storage.carbaccfiles,
                  azurerm_postgresql_flexible_server_database.carbaccdb
               ]
}

resource "azapi_resource" "carbacc_taskmanagement_service" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.carbacc_taskmanagement_service_name
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
          targetPort = 80
          traffic = [
            {
              latestRevision = true
              weight = 100
            }
          ]
           corsPolicy = {
                    allowedOrigins = [
                        "https://carbacc-frontend-service.${var.default_domain}",
                        "https://${var.customer}.afcsoftware.com",
                        "https://${var.customer}.afcdemo.com"
                    ],
                    allowedMethods = [
                        "*"
                    ],
                    allowedHeaders = [
                        "*"
                    ],
                    exposeHeaders: null,
                    maxAge: 0,
                    allowCredentials: false
                }
        }
        activeRevisionsMode = "Single"
      }
      environmentId = var.container_app_environment_id
      template = {
        containers = [
          {
            name = "carbacc-taskmanagement-service"
            image = local.carbacc_taskmanagement_service_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
            }
            env = [
      {
        name        = "ESG_ConnectionString"
        value       = "Host=${var.database_server_url};Port=5432;Username=${var.database_user};Password=${var.database_password};Database=${var.database_database}"
      },
      {
        name  = "ASPNETCORE_URLS"
        value= "http://+:80"
      },
      {
        name  = "ExportServiceActive"
        value= "false"
      },
      {
        name  = "USER_DOCUMENT_STORAGE_ROOT_LOCATION"
        value= "/carbacc/files"
      },
      {
        name  = "ESG_VersionNumber"
        value= var.carbacc_version
      },
      {
        name  = "RABBITMQ_HOST"
        value = var.rabbitmq_name
      },
      {
        name  = "RABBITMQ_PORT"
        value = "5672"
      },
      {
        name  = "RABBITMQ_VHOST"
        value = var.customer
      },
      {
        name  = "RABBITMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name        = "RABBITMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
      {
        name  = "KeyCloakUri"
        value = var.keycloak_url
      },
      {
        name  = "KC_REALM"
        value = var.keycloak_realm
      },
      {
        name  = "KC_AUDIENCE"
        value = var.keycloak_client_id
      }    
            ]
            volumeMounts = [
              {
                volumeName = "carbaccfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "carbaccfiles"
            storageName = azurerm_container_app_environment_storage.carbaccfiles.name
            storageType = "AzureFile"
          }
        
        ]
        scale = {
          minReplicas = 1
          maxReplicas = var.max_replicas
        }
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
  depends_on = [  azurerm_container_app_environment_storage.carbaccfiles,
                  azurerm_postgresql_flexible_server_database.carbaccdb
               ]
}

resource "azapi_resource" "carbacc_sourceload_service" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.carbacc_souceload_service_name
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
          targetPort = 80
          traffic = [
            {
              latestRevision = true
              weight = 100
            }
          ]
          corsPolicy = {
                    allowedOrigins = [
                        "https://carbacc-frontend-service.${var.default_domain}",
                        "https://${var.customer}.afcsoftware.com",
                        "https://${var.customer}.afcdemo.com"
                    ],
                    allowedMethods = [
                        "*"
                    ],
                    allowedHeaders = [
                        "*"
                    ],
                    exposeHeaders: null,
                    maxAge: 0,
                    allowCredentials: false
                }
        }
        activeRevisionsMode = "Single"
      }
      environmentId = var.container_app_environment_id
      template = {
        containers = [
          {
            name = "carbacc-sourceload-service"
            image = local.carbacc_sourceload_service_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
            }
            env = [
      {
        name        = "ESG_ConnectionString"
        value       = "Host=${var.database_server_url};Port=5432;Username=${var.database_user};Password=${var.database_password};Database=${var.database_database}"
      },
      {
        name  = "ASPNETCORE_URLS"
        value= "http://+:80"
      },
      {
        name  = "ESG_VersionNumber"
        value= var.carbacc_version
      },
      {
        name  = "RABBITMQ_HOST"
        value = var.rabbitmq_name
      },
      {
        name  = "RABBITMQ_PORT"
        value = "5672"
      },
      {
        name  = "RABBITMQ_VHOST"
        value = var.customer
      },
      {
        name  = "RABBITMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name        = "RABBITMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
      {
        name  = "KeyCloakUri"
        value = var.keycloak_url
      },
      {
        name  = "KC_REALM"
        value = var.keycloak_realm
      },
      {
        name  = "KC_AUDIENCE"
        value = var.keycloak_client_id
      }    
            ]
            volumeMounts = [
              {
                volumeName = "carbaccfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "carbaccfiles"
            storageName = azurerm_container_app_environment_storage.carbaccfiles.name
            storageType = "AzureFile"
          }
        
        ]
        scale = {
          minReplicas = 1
          maxReplicas = var.max_replicas
        }
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
  depends_on = [  azurerm_container_app_environment_storage.carbaccfiles,
                  azurerm_postgresql_flexible_server_database.carbaccdb
               ]
}
