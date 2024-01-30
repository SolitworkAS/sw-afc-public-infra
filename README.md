# 1. Deployment

## 1.1 Pre-requisites

Before starting, ensure you have: 

- **Azure Access**: Credentials for the Azure Tenant and Subscription where the apps will be hosted.
  - Tenand id
  - Subscription id
- **Container Registry Access**: Solitwork Azure Container Registry credentials (provided by Solitwork).
- **Secure Credentials**: Create strong passwords for:
  - Reporting User
  - Admin User
  - Database User
  - RabbitMQ User
- **SMTP Configuration**:
  - Email Address (e.g., noreply@yourdomain.com)
  - Host (e.g., smtp.serveraddress.com)
  - Port (Typically 25, 465, or 587)
  - Username (Usually same as Email Address)
  - Password (Password the User)


## 1.2 Requirements

Before proceeding, make sure you have the following tools installed:

1. Install the official [Terraform](https://www.terraform.io/) CLI. 
2. Install the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
3. Ensure Git is installed on your machine.

## 1.3 Installing

Follow these steps to deploy the infrastructure:

1. Open the terminal and navigate to the desired folder.

2. Clone the infrastructure repository

    ```bash
    git clone https://github.com/SolitworkAS/sw-afc-public-infra
    cd sw-afc-public-infra    
    ```

3. Create and configure the `terraform.tfvars` file in the `sw-afc-public-infra` directory. Ensure all variables are filled out correctly. Here's the template: 

```hcl
# Customer Information
customer = ""  # Customer name or abbreviation

# Container Registry Configuration (provided by Solitwork)
container_registry          = ""
container_registry_username = ""
container_registry_password = ""

# Internal Product Components Passwords
rabbitmq_password           = ""
keycloak_admin_password     = "" # Password for the admin user in keycloak, the user management server
database_password           = ""

# Reporting User Password
reportingpassword           = ""

# Initial Admin User Information for ESG Application
app_admin_email             = ""
app_admin_first_name        = ""
app_admin_last_name         = ""
app_admin_initial_password  = ""

# SMTP Configuration for Sending Signup Emails, Notifications, etc.
smtp_from                   = "" # Example: noreply@yourdomain.com
smtp_host                   = "" # Example: smtp.serveraddress.com
smtp_port                   = "" # Common ports are 25, 465, 587
smtp_username               = "" # Often the same as smtp_from
smtp_password               = "" # Secure password for SMTP server

# Product Deployment Options
include_esg                 = false # Set to true if you are an ESG customer
include_carbacc             = false # Set to true if you are an ESG customer
include_vat                 = false # Set to true if you are a VAT customer
```

4. Initialize Terraform:

    ```bash
    terraform init
    ```

5. Login to the azure tenant and subscription that should host the installation
    ```bash
    az login --tenant "<tenant-id>"
    az account set --subscription "<subscription-id>"
    ```

6. Run the following command to deploy:

    ```bash
    terraform apply
    ```

    Confirm with "yes" when prompted.

7. After the deployment completes, you can access the deployed resources.

## 1.4 Updating

Follow these steps to deploy updates:

1. Open the terminal and navigate to the `sw-afc-public-infra` folder.
2. Pull updates from the infrastructure repository

    ```bash
    git pull
    ```
3. Login to the azure tenant and subscription that hosts the installation
    ```bash
    az login --tenant "<tenant-id>"
    az account set --subscription "<subscription-id>"
    ```
4. Upgrade Terraform providers:
    ```bash
    terraform init --upgrade
    ```
5. Run the following command to deploy:

    ```bash
    terraform apply
    ```

    Confirm with "yes" when prompted.
6. After the deployment completes, the application is updated.
