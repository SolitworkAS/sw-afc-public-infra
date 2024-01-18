# GENERAL VARIABLES
variable "customer" {
  default = "customer"
  description = "shorthand abbrieviation for customer name, must only contain lowercase letters and numbers"
  validation {
    condition = can(regex("^[a-z0-9]+$", var.customer))
    error_message = "customer must only contain lowercase letters and numbers"
  }
}
variable "carbacc_version" {
  description = "version of carbacc to deploy"
}
variable "container_app_environment_id" {
  description = "id of the container app environment, must be a valid Azure resource id"
}
variable "resource_group_name" {
  description = "name of the resource group, must only contain lowercase letters, numbers and dashes"  
}
variable "resource_group_id" {
  description = "id of the resource group, must be a valid Azure resource id"
}
variable "location" {
  description = "location of the resource group, must be a valid Azure location"
}

# SCALING VARIABLES
variable "min_replicas" {
  default = 0
  description = "minimum number of replicas, must be a number, use 0 to allow scaling to 0 to reduce costs"
  validation {
    condition = can(regex("^[0-9]+$", var.min_replicas))
    error_message = "min_replicas must be a number"
  }
}
variable "max_replicas" {
  default = 10
  description = "maximum number of replicas, must be a number"
  validation {
    condition = can(regex("^[0-9]+$", var.max_replicas))
    error_message = "max_replicas must be a number"
  }  
}

# STORAGE VARIABLES
variable "storage_account_name_carbacc" {
  description = "name of the storage account, must only contain lowercase letters, numbers and dashes"
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.storage_account_name_carbacc))
    error_message = "storage_account_name must only contain lowercase letters, numbers and dashes"
  } 
}
variable "storage_quota" {
  default = 100
  description = "storage quota in GB, must be a number"
  validation {
    condition = can(regex("^[0-9]+$", var.storage_quota))
    error_message = "storage_quota must be a number"
  }
}
variable "storage_access_tier" {
  default = "Hot"
  description = "storage access tier, must be a valid Azure storage access tier"
  validation {
    condition = can(regex("^(Hot|Cool)$", var.storage_access_tier))
    error_message = "storage_access_tier must be a valid Azure storage access tier"
  }
}
variable "storage_primary_access_key_carbacc" {
  description = "storage primary access key, must not be empty"
}

# CONTAINER REGISTRY VARIABLES
variable "container_registry" {
  default = "imagesdevregistry.azurecr.io"
  description = "container registry url"
}

variable "container_registry_username" {
  description = "container registry username, must not be empty"
  validation {
    condition = can(regex("^.{1,}$", var.container_registry_username))
    error_message = "container_registry_username must not be empty"
  }
}

variable "container_registry_password" {
  description = "container registry password, must not be empty"
  sensitive = true
  validation {
    condition = can(regex("^.{1,}$", var.container_registry_password))
    error_message = "container_registry_password must not be empty"
  }
}

# DATABASE VARIABLES
variable "database_server_url" {
  description = "database server url"
}

variable "database_server_id" {
  description = "database server id (azure resource id)"
}

variable "database_database" {
  default = "carbacc-db"
  description = "database name, must only contain lowercase letters, numbers and dashes"
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.database_database))
    error_message = "database_database must only contain lowercase letters, numbers and dashes"
  }
}

variable "database_user" {
  description = "database admin user, must only contain lowercase letters and numbers"
  validation {
    condition = can(regex("^[a-z0-9]+$", var.database_user))
    error_message = "dbuser must only contain lowercase letters and numbers"
  }
}

variable "database_password" {
  description = "database admin password, must be at least 8 characters long"
  sensitive = true
  validation {
    condition = can(regex("^.{8,}$", var.database_password))
    error_message = "dbpassword must be at least 8 characters long"
  }
}

# RABBITMQ VARIABLES
variable "rabbitmq_image" {
  default = "rabbitmq:3.12.6"
  description = "docker image for rabbitmq"
}

variable "rabbitmq_user" {
  description = "RabbitMQ default user, must only contain lowercase letters and numbers"
  validation {
    condition = can(regex("^[a-z0-9]+$", var.rabbitmq_user))
    error_message = "rabbitmq_user must only contain lowercase letters and numbers"
  }
}

variable "rabbitmq_password" {
  description = "password for RabbitMQ default user, must be at least 8 characters long"
  sensitive = true
  validation {
    condition = can(regex("^.{8,}$", var.rabbitmq_password))
    error_message = "rabbitmq_password must be at least 8 characters long"
  }
}

# KEYCLOAK VARIABLES
variable "keycloak_url" {
  description = "Keycloak url, must be a valid url (fully qualified domain name)"
}

variable "rabbitmq_name" {
  description = "name of the rabbitmq container app, must only contain lowercase letters, numbers and dashes"
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.rabbitmq_name))
    error_message = "rabbitmq_name must only contain lowercase letters, numbers and dashes"
  }
}
variable "keycloak_realm" {
  default = "customera"
  description = "Keycloak realm, must only contain lowercase letters and numbers"
  validation {
    condition = can(regex("^[a-z0-9]+$", var.keycloak_realm))
    error_message = "keycloak_realm must only contain lowercase letters and numbers"
  }
}
variable "keycloak_client_id" {
  default = "afc-carbacc"
  description = "keycloak client id, must only contain lowercase letters, numbers and dashes"
  validation {
    condition = can(regex("^[a-z0-9-]+$", var.keycloak_client_id))
    error_message = "keycloak_client_id must only contain lowercase letters, numbers and dashes"
  }
}

variable "reportingpassword" {
  description = "password for reporting user, must be at least 8 characters long"
  sensitive = true
  validation {
    condition = can(regex("^.{8,}$", var.reportingpassword))
    error_message = "email must be at least 8 characters long"
  }
}
variable "default_domain"{
  description = "default domain"
}