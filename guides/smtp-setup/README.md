# SMTP Guide

This is a guide on how to create a compatible SMTP setup. By the end of the guide you should obtain the necessary stmp credentials (username, password, email, smtp server, and port)


# Table of Contents
- [SMTP Guide](#smtp-guide)
- [Table of Contents](#table-of-contents)
- [Part 1: Creating Email Communication Service Resource](#part-1-creating-email-communication-service-resource)
  - [Part 1: Creating Email Communication Service Resource](#part-1-creating-email-communication-service-resource-1)
  - [Part 2: Setting Up Managed Domain](#part-2-setting-up-managed-domain)
  - [Part 3: Connecting a Verified Email Domain](#part-3-connecting-a-verified-email-domain)
  - [Step 4: Registering an Application with Microsoft Entra ID and Creating a Service Principal](#step-4-registering-an-application-with-microsoft-entra-id-and-creating-a-service-principal)
  - [Step 5: Using a Microsoft Entra Application with Azure Communication Services Resource for SMTP](#step-5-using-a-microsoft-entra-application-with-azure-communication-services-resource-for-smtp)
    - [Creating a Custom Email Role for the Entra Application](#creating-a-custom-email-role-for-the-entra-application)
    - [Assigning Custom Email Role to Entra Application](#assigning-custom-email-role-to-entra-application)
  - [Step 6: Creating SMTP Credentials from Entra Application Information](#step-6-creating-smtp-credentials-from-entra-application-information)

# Part 1: Creating Email Communication Service Resource

## Part 1: Creating Email Communication Service Resource

1. **Open the Azure portal:** 
   - Navigate to [Azure portal](https://portal.azure.com/).

2. **Search for Email Communication Services:** 
   - In the search bar at the top, type "Email Communication Services".
![Email Communication Services](./pics/section1/email-communication-search.png)
  

1. **Select Email Communication Services and press Create:** 
   - Click on "Email Communication Services" from the search results, then press the "Create" button.
![Email Communication Services](./pics/section1/email-communication-create.png)


2. **Select Azure Subscription and Resource Group:**
   - Choose the Azure subscription you want to use.
   - Select an existing resource group or create a new one by clicking "Create new" and providing a name.

3. **Provide Resource Details:**
   - Enter a valid name for the resource.
   - Select "Europe" as the data location.

4. **Add Tags (Optional):**
   - If necessary, add any name/value pairs for tagging purposes.

5. **Review and Create:**
   - Click on "Next: Review + create".

![Email Communication Services](./pics/section1/email-communication-create-review.png)


6. **Review Details and Create Resource:**
   - Review the details of your resource configuration.
   - Click "Create" to provision the Email Communication Service resource.
  
![Email Communication Services](./pics/section1/email-communication-overview.png)


## Part 2: Setting Up Managed Domain

1. **Open the Overview page of the Email Communications Service resource:**
   - Navigate to the Overview page of the Email Communication Service resource created in the previous step.

2. **Create an Azure Managed Domain:**

   - **Option 1: Add Free Azure Subdomain**
     - Click on the "1-click add" button under "Add a free Azure subdomain".
    ![Email Communication Services](./pics/section2/email-add-azure-domain-created.png)


   - **Option 2: Provision Custom Domain**
     - If you prefer a custom domain, click on "Provision Domains" on the left navigation panel.
     - Click "Add domain" on the upper navigation bar.
     - Select "Azure domain" from the dropdown.
    

3. **Wait for Deployment:**
   - If you chose Option 1, wait for the deployment to complete.
    ![Email Communication Services](./pics/section2/email-add-azure-domain-progress.png)

4. **View Provisioned Domain:**
   - Once the domain is created, you'll see a list view with the new domain.
    ![Email Communication Services](./pics/section2/email-add-azure-domain-created.png)
   - Click on the name of the provisioned domain to open the overview page for the domain resource type.
    ![Email Communication Services](./pics/section2/email-azure-domain-overview.png)


## Part 3: Connecting a Verified Email Domain

1. **Create Azure Communication Service Resource:**
   - Navigate to your resource group where the communication email service was created
   - Select Create
   - Search for "Azure Communication Service"
   ![Email Communication Services](./pics/section3/create-comm.png)
   - Create the resource and give it a name

2. **Access Azure Communication Service Resource Overview:**
   - After creating the Azure Communication service, navigate to it and get to the overview page.
    ![Email Communication Services](./pics/section3/email-domains.png)

3. **Navigate to Domains:**
   - Click on "Domains" on the left navigation panel under Email.

4. **Connect Verified Email Domain:**
   - Choose one of the following options:
     - **Option 1:** Click "Connect domain" in the upper navigation bar.
     - **Option 2:** Click "Connect domain" in the splash screen.
    ![Email Communication Services](./pics/section3/email-domains-connect.png)
5. **Select Verified Domain:**
   - Filter and select the verified domain based on:
     - Subscription
     - Resource Group
     - Email Service
     - Verified Domain
   - If you deployed an Azure domain, you'll likely have only one option displayed.
    ![Email Communication Services](./pics/section3/email-domains-connect-select.png)
   
6. **Click Connect:**
   - After selecting the verified domain, click "Connect".
    ![Email Communication Services](./pics/section3/email-domains-connected.png)

## Step 4: Registering an Application with Microsoft Entra ID and Creating a Service Principal

1. **Sign in to Microsoft Entra Admin Center:**
   - Log in as at least a Cloud Application Administrator.

2. **Navigate to Application Registration:**
   - Go to Identity > Applications > App registrations and select "New registration".

3. **Name and Configure Application:**
   - Name the application (e.g., "example-app").
   - Select a supported account type.
   - Under Redirect URI, select "Web" and leave the uri field blank.
   - Click "Register".
    ![Email Communication Services](./pics/section4/create-app.png)

4. **Assign Role to Application:**
   - Sign in to the Azure portal.
   - Choose the scope level (e.g., subscription, resource group, or resource).
   - Navigate to Access control (IAM) and click "Add role assignment".
   - Choose the role (e.g., Contributor) and select the application as a member.
   - Click "Review + assign".
    ![Email Communication Services](./pics/section4/add-role-assignment.png)

5. **Set Up Authentication for Service Principal:**

   - **Create a New Client Secret:**
     - Browse to Identity > Applications > App registrations and select your application.
     - Go to Certificates & secrets > Client secrets and click "New client secret".
     - Provide a description and duration for the secret.
     - Click "Add".
     - Copy and store the client secret securely for later use.
    ![Email Communication Services](./pics/section4/copy-secret.png)


## Step 5: Using a Microsoft Entra Application with Azure Communication Services Resource for SMTP

### Creating a Custom Email Role for the Entra Application

1. **Create Custom Role:**
   - Navigate to the subscription, resource group, or Azure Communication Service Resource where the custom role should be assignable.
   - Open Access control (IAM).
     ![Email Communication Services](./pics/section5/smtp-custom-role-iam%20(1).png)
   - Click on the "Roles" tab to see a list of all built-in and custom roles.
   - Search for a role to clone (e.g., Reader).
   - Click the ellipsis (...) at the end of the row and then click "Clone".
     ![Email Communication Services](./pics/section5/smtp-custom-role-clone.png)

2. **Configure Custom Role:**
   - Click on the "Basics" tab and give a name to the new role.
     ![Email Communication Services](./pics/section5/smtp-custom-role-basics.png)
   - Go to the "Permissions" tab and click "Add permissions".
     ![Email Communication Services](./pics/section5/smtp-custom-role-add-permissions.png)
   - Search for "Microsoft.Communication" and select "Azure Communication Services".
   - Select the "Microsoft.Communication/CommunicationServices Read" and "Microsoft.Communication/EmailServices Write" permissions.
     ![Email Communication Services](./pics/section5/smtp-custom-role-permissions.png)
   - Click "Add".
   - Review the permissions for the new role, then click "Review + create" and subsequently "Create" on the next page.
     ![Email Communication Services](./pics/section5/smtp-custom-role-review.png)

### Assigning Custom Email Role to Entra Application

1. **Assign Role:**
   - Navigate to the subscription, resource group, or Azure Communication Service Resource where the custom role should be assignable.
   - Open Access control (IAM).
     ![Email Communication Services](./pics/section5/smtp-custom-role-iam%20(1).png)
   - Click "+Add" and select "Add role assignment".
     ![Email Communication Services](./pics/section5/email-smtp-add-role-assignment.png)

2. **Configure Role Assignment:**
   - On the Role tab, select the custom role created for sending emails using SMTP and click "Next".
     ![Email Communication Services](./pics/section5/email-smtp-select-custom-role.png)
   - On the Members tab, choose "User, group, or service principal" and click "+Select members".
     ![Email Communication Services](./pics/section5/email-smtp-select-members.png)
   - Search for the Entra application used for authentication and select it, then click "Select".
     ![Email Communication Services](./pics/section5/email-smtp-select-entra.png)
   - After confirming the selection, click "Next".
     ![Email Communication Services](./pics/section5/email-smtp-select-review.png)
   - Confirm the scope and members, then click "Review + assign".
     ![Email Communication Services](./pics/section5/email-smtp-select-assign.png)

## Step 6: Creating SMTP Credentials from Entra Application Information

   To be able to use these credentials for SMTP some adjustments need to be made.

 1. **SMTP Authentication Username:**
  - Construct the username using the following format:
    ```
    <Azure Communication Services Resource name>.<Entra Application ID>.<Entra Tenant ID>
    ```
 2. **SMTP Authentication Password:**
  - Password: Use the secret created earlier for the app registration.
    ![Email Communication Services](./pics/section5/email-smtp-entra-secret.png)

 3. **SMTP From:**
  - Navigate to the resource group where the email communication service has been created
   ![Email Communication Services](./pics/section2/email-add-azure-domain.png)
  - Select provision domains page
   ![Email Communication Services](./pics/section2/email-add-azure-domain-created.png)
  - Click on the domain created earlier
  - Select the mail from page
   ![Email Communication Services](./pics/section5/mail-from.png)
  - Copy the email address shown


 4. **Using the credentials:**
   To use these credentials we need to navigate to the tfvars file and modify the following fields:

   - smtp_from                   = smtp from as shown above
   - smtp_host                   = "smtp.azurecomm.net"
   - smtp_port                   = 587 
   - smtp_username               = username as shown above
   - smtp_password               = password as shown above

 5. **Deployment**
    Update the tfvars file and run terraform apply to use the new SMTP setup




