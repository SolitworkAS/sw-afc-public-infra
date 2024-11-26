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
  # ESG Disclosure Management
  esg_disclosure_management_name  = "esg-disclosure-management"
  esg_disclosure_management_image = "${var.container_registry}/images/esg/disclosure_management:${var.esg_version}"
  esg_disclosure_management_init_image  = "${var.container_registry}/images/esg/disclosure_management_init:${var.esg_version}"
  
  # External Endpoints

  external_endpoints_name  = "external-endpoints"
  external_endpoints_image = "${var.container_registry}/images/esg/external_endpoints:${var.esg_version}"


  # CSV service

  esg_csv_service_name  = "esg-csv-service"
  esg_csv_service_image = "${var.container_registry}/images/esg/csv_importer:${var.esg_version}"
  # ESG Jobs

  esg_job_notification_name  = "esg-job-notification-manager"
  esg_job_notification_image = "${var.container_registry}/images/esg/job_notifications:${var.esg_version}"
  esg_job_schedulation_name  = "esg-job-schedulation-manager"
  esg_job_schedulation_image = "${var.container_registry}/images/esg/job_schedulations:${var.esg_version}"

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
  lifecycle { 
  prevent_destroy = true
  }
}

resource "azurerm_container_app_environment_storage" "esgfiles" {
  name                         = "esgfiles"
  container_app_environment_id = var.container_app_environment_id
  account_name                 = var.storage_account_name_esg
  share_name                   = azurerm_storage_share.esgshare.name
  access_key                   = var.storage_primary_access_key_esg
  access_mode                  = "ReadWrite"
  lifecycle { 
  prevent_destroy = true
  }
  depends_on                   = [ azurerm_storage_share.esgshare]
}

resource "azurerm_backup_protected_file_share" "esgprotectedfileshare" {
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name
  source_file_share_name = azurerm_storage_share.esgshare.name
  source_storage_account_id = var.source_storage_account_id
  backup_policy_id = var.backup_policy_id
  depends_on = [ azurerm_container_app_environment_storage.esgfiles, azurerm_storage_share.esgshare]
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
            value = var.smtp_password
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
                        "https://esg-frontend-service.${var.default_domain}",
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
            name = "esg-notification-manager"
            image = local.esg_notification_manager_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
        value = var.smtp_port
      },
      {
        name        = "EMAIL_SMTP_SERVER"
        value = var.smtp_host
      },
      {
        name        = "EMAIL_LOGIN"
        value = var.smtp_username
      },
      {
        name        = "EMAIL_FROM"
        value = var.smtp_from
      },
      {
        name        = "EMAIL_PASSWORD"
        secretRef = "emailpassword"
      },
      {
        name = "LOGIN_PAGE"
        value = "https://esg-frontend-service.${var.default_domain}"
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
          },
          {
            name = "posthogkey"
            value = var.posthogkey
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
              cpu = var.min_cpu
              memory = var.min_memory
            }
            env = [
      {
        name  = "VERSION"
        value = var.esg_version
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
        name  = "DISCLOSURE_MANAGEMENT_API"
        value = "https://${jsondecode(azapi_resource.esg_disclosure_management.output).properties.configuration.ingress.fqdn}"
      },
      {
        name = "CARBACC_URL"
        value = var.carbacc_frontend_url
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
        name = "POSTHOG_KEY"
        secretRef = "posthogkey"
      },
      {
        name = "POSTHOG_HOST"
        value = var.posthoghost
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
                        "https://esg-frontend-service.${var.default_domain}",
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
            name = "esg-reporting-manager"
            image = local.esg_reporting_manager_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
                        "https://esg-frontend-service.${var.default_domain}",
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
            name = "esg-user-management"
            image = local.esg_user_management_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
          minReplicas = 1
          maxReplicas = var.max_replicas
        }
        initContainers = [
          {
            name = "esg-user-management-init"
            image = local.esg_user_management_init
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
                        "https://esg-frontend-service.${var.default_domain}",
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
            name = "esg-survey-manager"
            image = local.esg_survey_manager_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
      ,
      {
        name  = "JOB_SURVEY_MANAGER_HOST"
        value = "https://esg-survey-manager.${var.env_domain}"
      }
      ,
      {
        name  = "JOB_ADMIN_USERNAME"
        value = "reporting@solitwork.com"
      }
      ,
      {
        name  = "JOB_ADMIN_PASSWORD"
        secretRef = "reportingpassword"
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
              cpu = var.min_cpu
              memory = var.min_memory
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
      ,
      {
        name  = "JOB_SURVEY_MANAGER_HOST"
        value = "https://esg-survey-manager.${var.env_domain}"
      }
      ,
      {
        name  = "JOB_ADMIN_USERNAME"
        value = "reporting@solitwork.com"
      }
      ,
      {
        name  = "JOB_ADMIN_PASSWORD"
        secretRef = "reportingpassword"
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

resource "azapi_resource" "esg_disclosure_management" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.esg_disclosure_management_name
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
                        "https://esg-frontend-service.${var.default_domain}",
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
            name = "esg-disclosure-management"
            image = local.esg_disclosure_management_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
      },
      {
        name  = "AUDIT_TRAIL_DOMAIN"
        value = "https://audit-trail-service.${var.env_domain}"
      },
      {
        name = "LOGIN_PAGE"
        value = "https://esg-frontend-service.${var.default_domain}"
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
            name = "esg-disclosure-management-init"
            image = local.esg_disclosure_management_init_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
      },
      {
        name  = "AUDIT_TRAIL_DOMAIN"
        value = "https://audit-trail-service.${var.env_domain}"
      },
      {
        name = "LOGIN_PAGE"
        value = "https://esg-frontend-service.${var.default_domain}"
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
                        "https://esg-frontend-service.${var.default_domain}",
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
            name = "esg-organization-module"
            image = local.esg_organization_module_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
          minReplicas = 1
          maxReplicas = var.max_replicas
        }
        initContainers = [
          {
            name = "esg-organization-module-init"
            image = local.esg_organization_module_init_image
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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

### CSV service

resource "azapi_resource" "esg_csv_service" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.esg_csv_service_name
  parent_id = var.resource_group_id
  location = var.location
  body = jsonencode({
    properties = {
      configuration = {
        secrets = [
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
            name = "esg-csv-service"
            image = local.esg_csv_service_image
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
              name = "CARBACC_URL"
              value = "https://carbacc-taskmanagement-service.${var.env_domain}"
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
      }
    }
  })
  response_export_values = [ "properties.configuration.ingress.fqdn", "properties.outboundIpAddresses" ]
  depends_on = [  azurerm_container_app_environment_storage.esgfiles,
                  azurerm_postgresql_flexible_server_database.esgdb
               ]
}

### External Endpoints

resource "azapi_resource" "external_endpoints" {
  type = "Microsoft.App/containerApps@2023-05-01"
  name = local.external_endpoints_name
  parent_id = var.resource_group_id
  location = var.location
  body = jsonencode({
    properties = {
      configuration = {
        secrets = [
          {
            name = "containerregistrypassword"
            value = var.container_registry_password
          },
          {
            name = "reportingpassword"
            value = var.reportingpassword
          },
          {
            name = "databasepassword"
            value = var.database_password
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
            name = "external-endpoints"
            image = local.external_endpoints_image
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
              name = "CARBACC_TASKMANAGEMENT_SERVICE"
              value = "https://carbacc-taskmanagement-service.${var.env_domain}"
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
            name  = "KEYCLOAK_REPORTING_USERNAME"
            value = "reporting@solitwork.com"
            }
            ,
            {
              name  = "KEYCLOAK_REPORTING_PASSWORD"
              secretRef = "reportingpassword"
            },
            {
              name  = "POSTGRES_SERVER_CARBACC"
              value = var.database_server_url
            },
            {
              name  = "POSTGRES_DB_CARBACC"
              value = "carbacc-db"
            },
            {
              name  = "POSTGRES_USER_CARBACC"
              value = var.database_user
            },
            {
              name        = "POSTGRES_PASSWORD_CARBACC"
              secretRef = "databasepassword"
            },
            {
              name        = "POSTGRES_SCHEMA_CARBACC"
              value = "taskmanagement"
            },
            {
              name        = "ESG_ORGANIZATION_MODULE_SERVICE"
              value = "https://esg-organization-module.${var.env_domain}"
            },
            {
              name        = "ESG_DISCLOSURE_MANAGEMENT_SERVICE"
              value = "https://esg-disclosure-management.${var.env_domain}"
            },
            {
              name        = "ESG_SURVEY_MANAGER_SERVICE"
              value = "https://esg-survey-manager.${var.env_domain}"
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

### Job containers



resource "azapi_resource" "esg-job-schedulations" {
  type      = "Microsoft.App/jobs@2023-05-02-preview"
  name      = local.esg_job_schedulation_name
  parent_id = var.resource_group_id
  location = var.location
  schema_validation_enabled = false
  
  body = jsonencode({
    properties = {
      configuration = {
        registries = [
          {
            server = var.container_registry
            username = var.container_registry_username
            passwordSecretRef = "containerregistrypassword"
          }
        ]
        replicaRetryLimit = 1
        replicaTimeout = 180
        scheduleTriggerConfig = {
          cronExpression = "0 6 * * *"
          parallelism = 1
          replicaCompletionCount = 1
        }
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
          },
          {
            name = "reportingpassword"
            value = var.reportingpassword
          }
        ]
        triggerType = "Schedule"
      }
      environmentId = var.container_app_environment_id
      template = {
        containers = [
          {
            image = local.esg_job_schedulation_image
            name = "esg-job-schedulation"
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
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
          ,
          {
            name  = "JOB_SURVEY_MANAGER_HOST"
            value = "https://${jsondecode(azapi_resource.esg_survey_manager.output).properties.configuration.ingress.fqdn}"
          }
          ,
          {
            name  = "JOB_ADMIN_USERNAME"
            value = "reporting@solitwork.com"
          }
          ,
          {
            name  = "JOB_ADMIN_PASSWORD"
            secretRef = "reportingpassword"
          }
                ]
          }
        ]
      }
    }
  })
}

resource "azapi_resource" "esg-job-notifications" {
  type = "Microsoft.App/jobs@2023-05-02-preview"
  name = local.esg_job_notification_name
  location = var.location
  parent_id = var.resource_group_id
  body = jsonencode({
    properties = {
      configuration = {
        registries = [
          {
            server = var.container_registry
            username = var.container_registry_username
            passwordSecretRef = "containerregistrypassword"
          }
        ]
        replicaRetryLimit = 1,
        replicaTimeout = 180,
        scheduleTriggerConfig = {
          cronExpression = "0 6 * * *",
          parallelism = 1,
          replicaCompletionCount = 1,
        }
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
          },
          {
            name = "reportingpassword"
            value = var.reportingpassword
          }
        ]
        triggerType = "Schedule"
      }
      environmentId = var.container_app_environment_id
      template = {
        containers = [
          {
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
          ,
          {
            name  = "JOB_SURVEY_MANAGER_HOST"
            value = "https://${jsondecode(azapi_resource.esg_survey_manager.output).properties.configuration.ingress.fqdn}"
          }
          ,
          {
            name  = "JOB_ADMIN_USERNAME"
            value = "reporting@solitwork.com"
          }
          ,
          {
            name  = "JOB_ADMIN_PASSWORD"
            secretRef = "reportingpassword"
          }
            ]
            image = local.esg_job_notification_image
            name = local.esg_job_notification_name
            resources = {
              cpu = var.min_cpu
              memory = var.min_memory
            }
          }
        ]
      }
    }
  })
}
