locals {

  # ESG Frontend
  esg_frontend_name  = "esg-frontend-service"
  esg_frontend_image = "${var.container_registry}/images/esg/frontend_service:${var.esg_version}"
  # ESG notification-manager
  esg_notification_manager_name  = "esg-notification-manager"
  esg_notification_manager_image = "${var.container_registry}/images/esg/notification_manager:${var.esg_version}"
  # ESG reporting-manager
  esg_reporting_manager_name  = "esg-reporting-manager"
  esg_reporting_manager_image = "${var.container_registry}/images/esg/reporting_manager:${var.esg_version}"
  # ESG user-management
  esg_user_management_name  = "esg-user-management"
  esg_user_management_image = "${var.container_registry}/images/esg/user_management:${var.esg_version}"
  esg_user_management_init  = "${var.container_registry}/images/esg/user_management_init:${var.esg_version}"
  # ESG organization-module
  esg_organization_module_name  = "esg-organization-module"
  esg_organization_module_image = "${var.container_registry}/images/esg/organization_module:${var.esg_version}"
  esg_organization_module_init_image  = "${var.container_registry}/images/esg/organization_module_init:${var.esg_version}"
  # ESG survey-manager
  esg_survey_manager_name  = "esg-survey-manager"
  esg_survey_manager_image = "${var.container_registry}/images/esg/survey_manager:${var.esg_version}"
  esg_survey_manager_init_image  = "${var.container_registry}/images/esg/survey_manager_init:${var.esg_version}"

  attachments_mount_path      = "/mnt/code/surveyfiles"
  # Queue configuration
  rabbitmq_name               = "rabbitmq"
  queue_chunk_size            = "10000"
  config_timeout_minutes      = "5"

  esgdb          = "${var.customer}-esg-db"
}

resource "azurerm_postgresql_flexible_server_database" "esgdb" {
  server_id  = var.database_server_id
  name       = var.database_database
  collation  = "en_US.utf8"
  charset    = "UTF8"
}

resource "azurerm_storage_share" "esgshare" {
  name                        = "esgshare"
  storage_account_name        = var.storage_account_name_esg
  quota                       = var.storage_quota
  access_tier                 = var.storage_access_tier
}

resource "azurerm_container_app_environment_storage" "esgfiles" {
  name                         = "esgfiles"
  container_app_environment_id = var.container_app_environment_id
  account_name                 = var.storage_account_name_esg
  share_name                   = azurerm_storage_share.esgshare.name
  access_key                   = var.storage_primary_access_key_esg
  access_mode                  = "ReadWrite"
  depends_on                   = [ azurerm_storage_share.esgshare]
}

resource "azapi_resource" "esg_notification_manager" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.esg_notification_manager_name
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
            name = "reportingpassword"
            value = var.reportingpassword
          },
          {
            name = "emailpassword"
            value = var.emailpassword
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
                        "https://esg-frontend-service.${var.default_domain}"
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
            name = "esg-notification-manager"
            image = local.esg_notification_manager_image
            resources = {
              cpu = 1
              memory = "2Gi"
            }
            env = [
              {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "VERSION"
        value = var.esg_version
      },
      {
        name  = "API_PATH"
        value = "/"
      },
      {
        name  = "SWAGGER_DOCS"
        value = "false"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
      {
        name        = "EMAIL_PORT"
        value = "587"
      },
      {
        name        = "EMAIL_SMTP_SERVER"
        value = "smtp.office365.com"
      },
      {
        name        = "EMAIL"
        value = "noreply@afcsoftware.com"
      },
      {
        name        = "EMAIL_PASSWORD"
        secretRef = "emailpassword"
      }
            ]
            volumeMounts = [
              {
                volumeName = "esgfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "esgfiles"
            storageName = azurerm_container_app_environment_storage.esgfiles.name
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
  depends_on = [  azurerm_container_app_environment_storage.esgfiles,
                  azurerm_postgresql_flexible_server_database.esgdb
               ]
}

resource "azapi_resource" "esg_frontend_service" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.esg_frontend_name
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
            name = "reportingpassword"
            value = var.reportingpassword
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
            name = "esg-frontend-service"
            image = local.esg_frontend_image
            resources = {
              cpu = 1
              memory = "2Gi"
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
        value = var.keycloak_client_id_esg
      },
      {
        name  = "USER_MANAGER_API"
        value = "https://${jsondecode(azapi_resource.esg_user_management.output).properties.configuration.ingress.fqdn}"
      },
      {
        name  = "ORGANIZATION_MANAGER_API"
        value = "https://${jsondecode(azapi_resource.esg_organization_module.output).properties.configuration.ingress.fqdn}"
      },
      {
        name  = "SURVEY_MANAGER_API"
        value = "https://${jsondecode(azapi_resource.esg_survey_manager.output).properties.configuration.ingress.fqdn}"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
            ]
            volumeMounts = [
              {
                volumeName = "esgfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "esgfiles"
            storageName = azurerm_container_app_environment_storage.esgfiles.name
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
  depends_on = [  azurerm_container_app_environment_storage.esgfiles,
                  azurerm_postgresql_flexible_server_database.esgdb
               ]
}

resource "azapi_resource" "esg_reporting_manager" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.esg_reporting_manager_name
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
            name = "reportingpassword"
            value = var.reportingpassword
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
                        "https://esg-frontend-service.${var.default_domain}"
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
            name = "esg-reporting-manager"
            image = local.esg_reporting_manager_image
            resources = {
              cpu = 1
              memory = "2Gi"
            }
            env = [
              {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "VERSION"
        value = var.esg_version
      },
      {
        name  = "API_PATH"
        value = "/"
      },
      {
        name  = "SWAGGER_DOCS"
        value = "True"
      },
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
        value = var.keycloak_client_id_esg
      },
      {
        name  = "KEYCLOAK_REPORTING_REALM"
        value = var.keycloak_realm
      },
      {
        name  = "KEYCLOAK_REPORTING_USERNAME"
        value = "reporting@solitwork.com"
      },
      {
        name        = "KEYCLOAK_REPORTING_PASSWORD"
        secretRef = "reportingpassword"
      },
      {
        name  = "REPORTING_HOST"
        value = "https://${jsondecode(azapi_resource.esg_survey_manager.output).properties.configuration.ingress.fqdn}"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      }
            ]
            volumeMounts = [
              {
                volumeName = "esgfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "esgfiles"
            storageName = azurerm_container_app_environment_storage.esgfiles.name
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
  depends_on = [  azurerm_container_app_environment_storage.esgfiles,
                  azurerm_postgresql_flexible_server_database.esgdb
               ]
}

resource "azapi_resource" "esg_user_management" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.esg_user_management_name
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
                        "https://esg-frontend-service.${var.default_domain}"
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
            name = "esg-user-management"
            image = local.esg_user_management_image
            resources = {
              cpu = 1
              memory = "2Gi"
            }
            env = [
              {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "VERSION"
        value = "0.1.0"
      },
      {
        name  = "API_PATH"
        value = "/"
      },
      {
        name  = "SWAGGER_DOCS"
        value = "false"
      },
      {
        name  = "POSTGRES_SERVER"
        value = var.database_server_url
      },
      {
        name  = "POSTGRES_DB"
        value = var.database_database
      },
      {
        name  = "POSTGRES_USER"
        value = var.database_user
      },
      {
        name        = "POSTGRES_PASSWORD"
        secretRef = "databasepassword"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
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
        value = var.keycloak_client_id_esg
      }
            ]
            volumeMounts = [
              {
                volumeName = "esgfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "esgfiles"
            storageName = azurerm_container_app_environment_storage.esgfiles.name
            storageType = "AzureFile"
          }
        
        ]
        scale = {
          minReplicas = var.min_replicas
          maxReplicas = var.max_replicas
        }
        initContainers = [
          {
            name = "esg-user-management-init"
            image = local.esg_user_management_init
            resources = {
              cpu = 0.25
              memory = "0.5Gi"
            }
            env = [
              {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "VERSION"
        value = "0.1.0"
      },
      {
        name  = "API_PATH"
        value = "/"
      },
      {
        name  = "SWAGGER_DOCS"
        value = "True"
      },
      {
        name  = "POSTGRES_SERVER"
        value = var.database_server_url
      },
      {
        name  = "POSTGRES_DB"
        value = var.database_database
      },
      {
        name  = "POSTGRES_USER"
        value = var.database_user
      },
      {
        name  = "APP_DB_PORT"
        value = "5432"
      },
      {
        name  = "FILE_UPLOAD_PATH"
        value = "/mnt/code/surveyfiles"
      },
      {
        name        = "POSTGRES_PASSWORD"
        secretRef = "databasepassword"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
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
        value = var.keycloak_client_id_esg
      }
            ]
          }
        ]
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
  depends_on = [  azurerm_container_app_environment_storage.esgfiles,
                  azurerm_postgresql_flexible_server_database.esgdb
               ]
}

resource "azapi_resource" "esg_survey_manager" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.esg_survey_manager_name
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
          targetPort = 80
          traffic = [
            {
              latestRevision = true
              weight = 100
            }
          ]
           corsPolicy = {
                    allowedOrigins = [
                        "https://esg-frontend-service.${var.default_domain}"
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
            name = "esg-survey-manager"
            image = local.esg_survey_manager_image
            resources = {
              cpu = 1
              memory = "2Gi"
            }
            env = [
              {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "VERSION"
        value = "0.1.0"
      },
      {
        name  = "API_PATH"
        value = "/"
      },
      {
        name  = "SWAGGER_DOCS"
        value = "false"
      },
      {
        name = "LOGIN_PAGE"
        value = "https://esg-frontend-service.${var.default_domain}"
      },
      {
        name  = "POSTGRES_SERVER"
        value = var.database_server_url
      },
      {
        name  = "POSTGRES_DB"
        value = var.database_database
      },
      {
        name  = "POSTGRES_USER"
        value = var.database_user
      },
      {
        name  = "FILE_UPLOAD_PATH"
        value = "/mnt/code/surveyfiles"
      },
      {
        name        = "POSTGRES_PASSWORD"
        secretRef = "databasepassword"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
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
        value = var.keycloak_client_id_esg
      }
            ]
            
            volumeMounts = [
              {
                volumeName = "esgfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "esgfiles"
            storageName = azurerm_container_app_environment_storage.esgfiles.name
            storageType = "AzureFile"
          }
        
        ]
        scale = {
          minReplicas = 1
          maxReplicas = var.max_replicas
        }
        initContainers = [
          {
            name = "esg-survey-manager-init"
            image = local.esg_survey_manager_init_image
            resources = {
              cpu = 0.25
              memory = "0.5Gi"
            }
            env = [
              {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "VERSION"
        value = "0.1.0"
      },
      {
        name  = "API_PATH"
        value = "/"
      },
      {
        name  = "SWAGGER_DOCS"
        value = "false"
      },
      {
        name  = "POSTGRES_SERVER"
        value = var.database_server_url
      },
      {
        name  = "POSTGRES_DB"
        value = var.database_database
      },
      {
        name  = "POSTGRES_USER"
        value = var.database_user
      },
      {
        name  = "APP_DB_PORT"
        value = "5432"
      },
      {
        name  = "FILE_UPLOAD_PATH"
        value = "/mnt/code/surveyfiles"
      },
      {
        name        = "POSTGRES_PASSWORD"
        secretRef = "databasepassword"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
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
        value = var.keycloak_client_id_esg
      }
            ]
          }
        ]
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
  depends_on = [  azurerm_container_app_environment_storage.esgfiles,
                  azurerm_postgresql_flexible_server_database.esgdb
               ]
}

resource "azapi_resource" "esg_organization_module" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.esg_organization_module_name
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
                        "https://esg-frontend-service.${var.default_domain}"
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
            name = "esg-organization-module"
            image = local.esg_organization_module_image
            resources = {
              cpu = 1
              memory = "2Gi"
            }
            env = [
              {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "VERSION"
        value = "0.1.0"
      },
      {
        name  = "API_PATH"
        value = "/"
      },
      {
        name  = "SWAGGER_DOCS"
        value = "false"
      },
      {
        name  = "POSTGRES_SERVER"
        value = var.database_server_url
      },
      {
        name  = "POSTGRES_DB"
        value = var.database_database
      },
      {
        name  = "POSTGRES_USER"
        value = var.database_user
      },
      {
        name        = "POSTGRES_PASSWORD"
        secretRef = "databasepassword"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
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
        value = var.keycloak_client_id_esg
      }
            ]
            volumeMounts = [
              {
                volumeName = "esgfiles"
                mountPath = local.attachments_mount_path
              }
            ]
          }
        ]
        volumes = [
          {
            name = "esgfiles"
            storageName = azurerm_container_app_environment_storage.esgfiles.name
            storageType = "AzureFile"
          }
        
        ]
        scale = {
          minReplicas = var.min_replicas
          maxReplicas = var.max_replicas
        }
        initContainers = [
          {
            name = "esg-organization-module-init"
            image = local.esg_organization_module_init_image
            resources = {
              cpu = 0.25
              memory = "0.5Gi"
            }
            env = [
              {
        name  = "LOG_LEVEL"
        value = "INFO"
      },
      {
        name  = "VERSION"
        value = "0.1.0"
      },
      {
        name  = "API_PATH"
        value = "/"
      },
      {
        name  = "SWAGGER_DOCS"
        value = "True"
      },
      {
        name  = "POSTGRES_SERVER"
        value = var.database_server_url
      },
      {
        name  = "POSTGRES_DB"
        value = var.database_database
      },
      {
        name  = "POSTGRES_USER"
        value = var.database_user
      },
      {
        name  = "APP_DB_PORT"
        value = "5432"
      },
      {
        name  = "FILE_UPLOAD_PATH"
        value = "/mnt/code/surveyfiles"
      },
      {
        name        = "POSTGRES_PASSWORD"
        secretRef = "databasepassword"
      },
      {
        name = "RBMQ_HOST"
        value = var.rabbitmq_host
      },
      {
        name = "RBMQ_PORT"
        value = "5672"
      },
      {
        name = "RBMQ_VHOST"
        value = var.customer
      },
      {
        name = "RBMQ_USER"
        value = var.rabbitmq_user
      },
      {
        name = "RBMQ_PASSWORD"
        secretRef = "rabbitmqpassword"
      },
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
        value = var.keycloak_client_id_esg
      }
            ]
          }
        ]
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
  depends_on = [  azurerm_container_app_environment_storage.esgfiles,
                  azurerm_postgresql_flexible_server_database.esgdb
               ]
}


