# sw-afc-public-infra

# 1. Deployment

## 1.1 Pre-requisites

Ensure you have the following pre-requisites in place:

- An Azure container registry containing the necessary applications.
- Azure credentials, including a username and password for the container registry.
- Values for credentials, such as the initial user, database password, application version to deploy, and SMTP values for user management (refer to `terraform.tfvars`).

## 1.2 Requirements

Before proceeding, make sure you have the following tools installed:

1. Install the official [Terraform](https://www.terraform.io/) CLI. Preferably, install it on a Linux environment.
2. Install the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli), also preferably on a Linux system.

Additionally, you need Git installed on your machine.

## 1.3 Instructions

Follow these steps to deploy the infrastructure:

1. Access the terminal and navigate to the desired folder.

2. Run the command to log in to your Azure tenant:

    ```bash
    az login
    ```

    This will open a browser to authenticate your Azure account.

3. Clone the infrastructure repository using Git:

    ```bash
    git clone https://github.com/SolitworkAS/sw-afc-public-infra
    ```

    Change to the cloned directory using:

    ```bash
    cd sw-afc-public-infra
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
