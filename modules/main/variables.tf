variable "include_vat" {
  description = "Include VAT"
  default     = false
}

variable "include_esg" {
  description = "Include ESG"
  default     = false
}

variable "use_proxy" {
  default     = false
  description = "Set to true if the proxy is used. It set's internal links so they are routed through the proxy"
}

variable "proxy_domain" {
  default     = "afcsoftware.com"
  description = "Star domain used by the proxy Eg. afcsoftware.com for customer1.afcsoftware.com"
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

variable "esg_version" {
  description = "version of esg and carbacc to deploy"
}

variable "esg_pbi_version" {
  description = "version of esg pbi to deploy"
  default     = "2025.02.1"
}

variable "vat_version" {
  description = "version of esg to deploy"
}

variable "keycloak_version" {
  default = "1.0.0"
}

variable "audit_version" {
  default = "1.0.0"
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
}

variable "database_user" {
  default     = "postgres"
  description = "database admin user, must only contain lowercase letters and numbers"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.database_user))
    error_message = "database_user must only contain lowercase letters and numbers"
  }
}

variable "database_password" {
  description = "database admin password, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.database_password))
    error_message = "database_password must be at least 8 characters long"
  }
}

# RABBITMQ VARIABLES
variable "rabbitmq_user" {
  default     = "rabbitmq"
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

variable "rabbitmq_image" {
  default     = "rabbitmq:3.12.6"
  description = "docker image for rabbitmq"
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

# STORAGE VARIABLES
variable "storage_account_name" {
  description = "storage account name, must be a valid Azure storage account name"
  default     = ""
}

variable "storage_access_tier" {
  default     = "Hot"
  description = "storage access tier, must be a valid Azure storage access tier"
}

variable "storage_quota" {
  default     = 100
  description = "storage quota in GB, must be a number"
  validation {
    condition     = can(regex("^[0-9]+$", var.storage_quota))
    error_message = "storage_quota must be a number"
  }
}

# SMTP VARIABLES
variable "smtp_host" {
  description = "SMTP host"
  validation {
    condition     = can(regex("^.{1,}$", var.smtp_host))
    error_message = "SMTP host must not be empty"
  }
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
  validation {
    condition     = can(regex("^.{1,}$", var.smtp_username))
    error_message = "SMTP username must not be empty"
  }
}

variable "smtp_password" {
  description = "SMTP password"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.smtp_password))
    error_message = "SMTP password must be at least 8 characters long"
  }
}

variable "smtp_from" {
  description = "SMTP from address, must be a valid email address"
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.smtp_from))
    error_message = "SMTP from address must be a valid email address"
  }
}

# APPLICATION ADMIN VARIABLES
variable "app_admin_email" {
  description = "Application admin email, must be a valid email address"
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.app_admin_email))
    error_message = "app_admin_email must be a valid email address"
  }
}

variable "app_admin_initial_password" {
  description = "Application admin initial password, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.app_admin_initial_password))
    error_message = "app_admin_initial_password must be at least 8 characters long"
  }
}

variable "app_admin_first_name" {
  description = "Application admin first name"
  validation {
    condition     = can(regex("^.{1,}$", var.app_admin_first_name))
    error_message = "app_admin_first_name must not be empty"
  }
}

variable "app_admin_last_name" {
  description = "Application admin last name"
  validation {
    condition     = can(regex("^.{1,}$", var.app_admin_last_name))
    error_message = "app_admin_last_name must not be empty"
  }
}

# REPORTING VARIABLES
variable "reportingpassword" {
  description = "password for reporting user, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.reportingpassword))
    error_message = "reportingpassword must be at least 8 characters long"
  }
}

# POSTHOG VARIABLES
variable "posthogkey" {
  description = "PostHog api token"
  sensitive   = true
}

variable "posthoghost" {
  description = "PostHog host"
  default     = "https://eu.i.posthog.com"
}

# RESOURCE VARIABLES
variable "min_cpu" {
  description = "minimum cpu"
}

variable "min_memory" {
  description = "minimum memory"
}

variable "availability_zone" {
  description = "availability zone"
}



