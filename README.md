# 1. Deployment

## 1.1 Pre-requisites

Before starting, ensure you have: 

- **Azure Access**: Credentials for the Azure Tenant and Subscription where the apps will be hosted.
  - Tenand id
  - Subscription id
- **Container Registry Access**: Solitwork Azure Container Registry credentials (provided by Solitwork).
- **Licence Key**: Secure code required to activate and use our product(s), ensuring access to its full features and benefits. (Provide by Solitwork)
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

# Licence key (provided by Solitwork)
license_key                 = "" # Licence key to verify our access to the product
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

7. After the deployment completes, terraform will output several urls essential for accessing and setting up the products. Please make sure to save them a conventient place. Find a detailed explanation of the urls and how to access and use them in the appendix below. 

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
6. After successful deployment, Terraform will output several URLs that are crucial for accessing and configuring the products. Save these URLs in a convenient place. 
7. Please go through section 1.5 URL Descriptions for a detailed explanation of the URLS and how to access them. 

## 1.5 URL Descriptions

After deployment, Terraform provides several URLs crucial for accessing and managing the deployed products. Below is a detailed description of each URL along with the access requirements:

| URL                         | Description                                                                                               | Access                                                                                                   |
|-----------------------------|-----------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| `carbacc_frontend_url`      | The user interface for carbon accounting.                                                                 | Requires a user created through the ESG user interface with Carbon rights.                               |
| `carbon_api_url`            | API interface for carbon accounting. Access documentation at `/swagger/index.html`.                       | Requires a user created through the ESG user interface. The user should have the Carbon role.                               |
| `esg_frontend_url`          | The user interface for ESG.                                                                               | Requires a user with at least the Respondent role. For initial access, use the Admin User details from `terraform.tfvars`. |
| `esg_organization_api`      | API interface for setting up organizations and departments in ESG. Access documentation at `/docs`.                                        | Requires a user created through the ESG user interface with Admin role.                                |
| `esg_reporting_api`         | API interface for obtaining ESG data for reporting purposes. Access documentation at `/docs`.                                             | Requires a user created through the ESG user interface with the Admin role.                                |
| `keycloak_url`              | The Keycloak server for setting up Single Sign-On (SSO) integration.                                      | Log in with the username `admin` and the admin password set in `terraform.tfvars`. Guide available in `sw-afc-public-infra/guides/sso-setup/README.md`.          |
| `vat_api_url`               | API interface for VAT.                                                                                    |                                                                                                          |
| `vat_frontend_url`          | The user interface for VAT.                                                                               |                                                                                                          |


## Frequently Asked Questions (FAQ)

### Q1: What should I do if I encounter an error stating `... context deadline exceeded ...` during installation or update?
**A:** This error often occurs due to issues with the internet connection. A simple solution is to try running the command `terraform apply` again. If the problem persists, ensure that your internet connection is stable and retry.

### Q2: Why aren't users receiving an invitation email after I create them in the ESG Users page?
**A:** To resolve this issue, first verify that your solution is correctly configured with a valid SMTP in the terraform.tfvars file, specifically under the "Initial Admin User Information for ESG Application" section. If this configuration is incomplete, please fill out all the required fields and execute the `terraform apply` command to apply the changes. This should ensure that invitation emails are sent out successfully. After a successful configuration, go to the ESG Users page, locate the users who need the invitation email, click the three dots next to each user, and select 'Resend Invitation Email'.

