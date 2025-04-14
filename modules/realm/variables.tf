variable "realm_name" {
  description = "Realm name, must only contain lowercase letters and numbers"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.realm_name))
    error_message = "Realm name must only contain lowercase letters and numbers"
  }
  
}

variable "smtp_host" {
  description = "SMTP host"
  validation {
    condition = can(regex("^.{1,}$", var.smtp_host))
    error_message = "SMTP host must not be empty"
  }
}
variable "smtp_port" {
  description = "SMTP port, must be a number"
  validation {
    condition = can(regex("^[0-9]+$", var.smtp_port))
    error_message = "SMTP port must be a number"
  }
}
variable "smtp_username" {
  description = "SMTP username"
  validation {
    condition = can(regex("^.{1,}$", var.smtp_username))
    error_message = "SMTP username must not be empty"
  }
}
variable "smtp_password" {
  description = "SMTP password"
  validation {
    condition = can(regex("^.{8,}$", var.smtp_password))
    error_message = "SMTP password must be at least 8 characters long"
  }
  sensitive = true
}
variable "smtp_from" {
  description = "SMTP from address, must be a valid email address"
  validation {
    condition = can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.smtp_from))
    error_message = "SMTP from address must be a valid email address"
  }
}

variable "login_theme" {
  description = "Keycloak login theme"
  default = "solitwork"
}
variable "email_theme" {
  description = "Keycloak email theme"
  default = "sw-custom-theme"
}

variable "vat_frontend_url" {
  description = "VAT frontend URL, must be a valid URL or empty string"
}

variable "esg_frontend_url" {
  description = "ESG frontend URL"
}


#APPLICATION ADMIN VARIABLES
variable "app_admin_email" {
  description = "Application admin email, must be a valid email address"
  validation {
    condition = can(regex("^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$", var.app_admin_email))
    error_message = "Application admin email must be a valid email address"
  }
}

variable "app_admin_initial_password" {
  description = "Application admin initial password, must be at least 8 characters long"
  validation {
    condition = can(regex("^.{8,}$", var.app_admin_initial_password))
    error_message = "Application admin initial password must be at least 8 characters long"
  }
}

variable "app_admin_first_name" {
  description = "Application admin first name"  
}

variable "app_admin_last_name" {
  description = "Application admin last name"
}
variable "keycloak_url" {
  description = "keycloak url"
}

variable "keycloak_admin_user" {
  default     = "admin"
  description = "Keycloak admin user, must only contain lowercase letters and numbers"
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.keycloak_admin_user))
    error_message = "keycloak_admin_user must only contain lowercase letters and numbers"
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

variable "keycloak_admin_password" {
  description = "password for Keycloak admin user, must be at least 8 characters long"
  sensitive   = true
  validation {
    condition     = can(regex("^.{8,}$", var.keycloak_admin_password))
    error_message = "keycloak_admin_password must be at least 8 characters long"
  }
}

variable "default_domain" {
  description = "default domain"
  
}