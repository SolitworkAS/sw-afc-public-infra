# GENERAL VARIABLES
variable "location" {
  description = "location of the resource group, must be a valid Azure location"
  validation {
    condition     = can(regex("^(westeurope|northeurope|uksouth|ukwest|eastus|eastus2|westus|westus2|centralus|northcentralus|southcentralus|westcentralus|canadacentral|canadaeast|brazilsouth|australiaeast|australiasoutheast|australiacentral|australiacentral2|eastasia|southeastasia|japaneast|japanwest|koreacentral|koreasouth|southindia|westindia|centralindia|francecentral|francesouth|germanywestcentral|norwayeast|swedencentral|switzerlandnorth|switzerlandwest|uaenorth|uaecentral|southafricanorth|southafricawest|eastus2euap|westus2euap|westcentralus|westus3|southafricawest2|australiacentral|australiacentral2|australiaeast|australiasoutheast|brazilsouth|canadacentral|canadaeast|centralindia|centralus|eastasia|eastus|eastus2|francecentral|francesouth|germanywestcentral|japaneast|japanwest|koreacentral|koreasouth|northcentralus|northeurope|norwayeast|southcentralus|southindia|southeastasia|swedencentral|switzerlandnorth|switzerlandwest|uaecentral|uaenorth|uksouth|ukwest|westcentralus|westeurope|westindia|westus|westus2)$", var.location))
    error_message = "location must be a valid Azure location"
  }
}

variable "resource_group_name" {
  description = "name of the resource group, must only contain lowercase letters, numbers and dashes"
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.resource_group_name))
    error_message = "ressource_group_name must only contain lowercase letters, numbers and dashes"
  }
}

variable "keycloak_version" {
  default     = "1.0.0"
}

variable "customer" {
  description = "shorthand abbrieviation for customer name, must only contain lowercase letters and numbers"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.customer))
    error_message = "customer must only contain lowercase letters and numbers"
  }
}

# CONTAINER REGISTRY VARIABLES
variable "container_registry" {
  description = "container registry url"
}

variable "availability_zone" {
  default     = "1"
  description = "availability zone, must be a valid Azure availability zone use 1 for north europe and 3 for west europe"
  validation {
    condition     = can(regex("^(1|2|3)$", var.availability_zone))
    error_message = "availability_zone must be a valid Azure availability zone"
  }
}

variable "container_registry_username" {
  description = "container registry username, must not be empty"
  validation {
    condition     = can(regex("^.{1,}$", var.container_registry_username))
    error_message = "container_registry_username must not be empty"
  }
}

variable "container_registry_password" {
  description = "container registry password, must not be empty"
  sensitive   = true
  validation {
    condition     = can(regex("^.{1,}$", var.container_registry_password))
    error_message = "container_registry_password must not be empty"
  }
}

# DATABASE VARIABLES
variable "database_sku" {
  default     = "B_Standard_B2s"
  description = "database sku, must be a valid Azure database sku"
}

variable "database_storage" {
  description = "database storage in MB, must be a valid Azure database storage size"
  validation {
    condition     = can(regex("^(32768|65536|131072|262144|524288|1048576|2097152|4193280|4194304|8388608|16777216|33553408)$", var.database_storage))
    error_message = "database_storage must be a valid Azure database storage size"
  }
}

variable "database_user" {
  description = "database admin user, must only contain lowercase letters and numbers"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.database_user))
    error_message = "dbuser must only contain lowercase letters and numbers"
  }
}

variable "database_password" {
  description = "database admin password, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.database_password))
    error_message = "dbpassword must be at least 8 characters long"
  }
}

# RABBITMQ

variable "rabbitmq_image" {
  default     = "rabbitmq:3.12.6"
  description = "docker image for rabbitmq"
}

variable "rabbitmq_user" {
  description = "RabbitMQ default user, must only contain lowercase letters and numbers"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.rabbitmq_user))
    error_message = "rabbitmq_user must only contain lowercase letters and numbers"
  }
}

variable "rabbitmq_password" {
  description = "password for RabbitMQ default user, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.rabbitmq_password))
    error_message = "rabbitmq_password must be at least 8 characters long"
  }
}


# KEYCLOAK VARIABLES
variable "keycloak_admin_user" {
  description = "Keycloak admin user, must only contain lowercase letters and numbers"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.keycloak_admin_user))
    error_message = "keycloak_admin_user must only contain lowercase letters and numbers"
  }
}

variable "keycloak_admin_password" {
  description = "password for Keycloak admin user, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.keycloak_admin_password))
    error_message = "keycloak_admin_password must be at least 8 characters long"
  }
}