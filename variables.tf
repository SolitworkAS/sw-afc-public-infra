variable "include_vat" {
  description = "Include VAT"
  default     = false
}

variable "include_esg" {
  description = "Include ESG"
  default     = false
}

variable "include_carbacc" {
  description = "Include CARBACC"
  default     = false
}


# GENERAL VARIABLES
variable "location" {
  default     = "northeurope"
  description = "location of the resource group, must be a valid Azure location"
  validation {
    condition     = can(regex("^(westeurope|northeurope|uksouth|ukwest|eastus|eastus2|westus|westus2|centralus|northcentralus|southcentralus|westcentralus|canadacentral|canadaeast|brazilsouth|australiaeast|australiasoutheast|australiacentral|australiacentral2|eastasia|southeastasia|japaneast|japanwest|koreacentral|koreasouth|southindia|westindia|centralindia|francecentral|francesouth|germanywestcentral|norwayeast|swedencentral|switzerlandnorth|switzerlandwest|uaenorth|uaecentral|southafricanorth|southafricawest|eastus2euap|westus2euap|westcentralus|westus3|southafricawest2|australiacentral|australiacentral2|australiaeast|australiasoutheast|brazilsouth|canadacentral|canadaeast|centralindia|centralus|eastasia|eastus|eastus2|francecentral|francesouth|germanywestcentral|japaneast|japanwest|koreacentral|koreasouth|northcentralus|northeurope|norwayeast|southcentralus|southindia|southeastasia|swedencentral|switzerlandnorth|switzerlandwest|uaecentral|uaenorth|uksouth|ukwest|westcentralus|westeurope|westindia|westus|westus2)$", var.location))
    error_message = "location must be a valid Azure location"
  }
}

variable "customer" {
  description = "shorthand abbrieviation for customer name, must only contain lowercase letters and numbers"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.customer))
    error_message = "customer must only contain lowercase letters and numbers"
  }
}

variable "carbacc_version" {
  description = "version of carbacc to deploy"
  default = "1.5.2"
}

variable "esg_version" {
  description = "version of esg to deploy"
  default = "1.2.1"
}

variable "vat_version" {
  description = "version of esg to deploy"
  default = "1.1.5"
}

variable "keycloak_version" {
  default     = "1.0.0"
}
# CONTAINER REGISTRY VARIABLES
variable "container_registry" {
  default     = "imagesdevregistry.azurecr.io"
  description = "container registry url"
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
  default     = "32768"
  description = "database storage in MB, must be a valid Azure database storage size"
  validation {
    condition     = can(regex("^(32768|65536|131072|262144|524288|1048576|2097152|4193280|4194304|8388608|16777216|33553408)$", var.database_storage))
    error_message = "database_storage must be a valid Azure database storage size"
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

variable "rabbitmq_password" {
  description = "password for RabbitMQ default user, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.rabbitmq_password))
    error_message = "rabbitmq_password must be at least 8 characters long"
  }
}

variable "reportingpassword" {
  description = "password for reporting user, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.reportingpassword))
    error_message = "email must be at least 8 characters long"
  }
}

variable "availability_zone" {
  default = "1"
  description = "availability zone"
}

# KEYCLOAK VARIABLES
variable "keycloak_admin_user" {
  default     = "admin"
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

# SCALING VARIABLES
variable "min_replicas" {
  default     = 0
  description = "minimum number of replicas, must be a number, use 0 to allow scaling to 0 to reduce costs"
  validation {
    condition     = can(regex("^[0-9]+$", var.min_replicas))
    error_message = "min_replicas must be a number"
  }
}
variable "max_replicas" {
  default     = 10
  description = "maximum number of replicas, must be a number"
  validation {
    condition     = can(regex("^[0-9]+$", var.max_replicas))
    error_message = "max_replicas must be a number"
  }
}
# SMTP VARIABLES
variable "smtp_host" {
  description = "SMTP host"
}
variable "smtp_port" {
  description = "SMTP port, must be a number"
  validation {
    condition     = can(regex("^[0-9]+$", var.smtp_port))
    error_message = "SMTP port must be a number"
  }
}
variable "smtp_username" {
  description = "SMTP username"
}
variable "smtp_password" {
  description = "SMTP password"
  sensitive   = true
}
variable "smtp_from" {
  description = "SMTP from address, must be a valid email address"
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.smtp_from))
    error_message = "SMTP from address must be a valid email address"
  }
}

#APPLICATION ADMIN VARIABLES
variable "app_admin_email" {
  description = "Application admin email, must be a valid email address"
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.app_admin_email))
    error_message = "Application admin email must be a valid email address"
  }
}

variable "app_admin_initial_password" {
  description = "Application admin initial password, must be at least 8 characters long"
  validation {
    condition     = can(regex("^.{8,}$", var.app_admin_initial_password))
    error_message = "Application admin initial password must be at least 8 characters long"
  }
}

variable "app_admin_first_name" {
  description = "Application admin first name"
}

variable "app_admin_last_name" {
  description = "Application admin last name"
}



