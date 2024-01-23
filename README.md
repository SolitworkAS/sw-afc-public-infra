# 1. Deployment

## 1.1 Pre-requisites

Ensure you have the following pre-requisites in place:

- Azure credentials, including a username and password for the container registry.
- Values for credentials, such as the initial user, database password, application version to deploy, and SMTP values for user management.
- An Azure Tenant and Subscription that should host the deployment.

## 1.2 Requirements

Before proceeding, make sure you have the following tools installed:

1. Install the official [Terraform](https://www.terraform.io/) CLI. 
2. Install the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
3. Ensure Git is installed on your machine.

## 1.3 Instructions

Follow these steps to deploy the infrastructure:

1. Access the terminal and navigate to the desired folder.

2. Clone the infrastructure repository using Git:

    ```bash
    git clone https://github.com/SolitworkAS/sw-afc-public-infra
    ```

    Change to the cloned directory using:

    ```bash
    cd sw-afc-public-infra
    ```

3. **Fill out the `terraform.tfvars` file:**
   Add the file `sw-afc-public-infra/terraform.tfvars` to the directory.  
   Add the content below to the file and fillout **all** the variables.

```hcl
# Customer Information
customer = ""  # Customer name or abbreviation

# Container Registry Configuration (provided by Solitwork)
container_registry          = ""
container_registry_username = ""
container_registry_password = ""

# Internal Product Components Passwords
rabbitmq_password           = ""
keycloak_admin_password     = ""
database_password           = ""

# Reporting User Password
reportingpassword           = ""

# Initial Admin User Information for ESG Application
app_admin_email             = ""
app_admin_first_name        = ""
app_admin_initial_password  = ""
app_admin_last_name         = ""

# SMTP Configuration for Sending Signup Emails, Notifications, etc.
smtp_from                   = "" # Email address for the sender. E.g. noreply@yourdomain.com
smtp_host                   = "" # Host of the email service. E.g. smtp.serveraddress.com
smtp_port                   = "" # Port for the identity provider email service
smtp_username               = "" # Username. Often the same as smtp_from.
smtp_password               = "" # Password for smtp_password. 

# Product to deploy
include_esg                 = false
include_carbacc             = false
include_vat                 = false
```

4. Initialize Terraform:

    ```bash
    terraform init
    ```

    If it's not the first time deploying, run:

    ```bash
    terraform init --upgrade
    ```

5. Run the following command to plan the deployment targeting the environment module:

    ```bash
    terraform plan -target="module.main.module.environment"
    ```

6. If the plan is successful, apply the changes:

    ```bash
    terraform apply -target="module.main.module.environment"
    ```

    The terminal will prompt you to confirm with "yes."

7. Once the environment is deployed, run the final Terraform apply command:

    ```bash
    terraform apply
    ```

    Confirm with "yes" when prompted.

8. After the deployment completes, you can access the deployed resources.
