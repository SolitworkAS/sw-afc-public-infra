# API Guide for ESG and Carbon Accounting

# Table of Contents
- [API Guide for ESG and Carbon Accounting](#api-guide-for-esg-and-carbon-accounting)
- [Table of Contents](#table-of-contents)
- [1 Introduction](#1-introduction)
- [2 Create User](#2-create-user)
- [3 Create organization and department entities.](#3-create-organization-and-department-entities)
- [4. Consequenses deleting and updating activities.](#4-consequenses-deleting-and-updating-activities)
  - [4.5.1 Manually Tagged:](#451-manually-tagged)
  - [4.5.2 Tagged By Accounting Rules:](#452-tagged-by-accounting-rules)
- [5. Reporting purposes](#5-reporting-purposes)

# 1 Introduction
Start by getting the URLS. The way to get them depends on who host the solution:  
* If Solitwork hosts, contact PST.  
* If Customer hosts, contact their IT department.  
All URL you'll need in the application follows the same structure. For instance, ESG which follows the structure below:  
`https://esg-frontend-service.<SOME-UNIQUE-STRING>.northeurope.azurecontainerapps.io/`
`<SOME-UNIQUE-STRING>` is the same for across all endpoints on the same customer.

Throughout this guide we will access the following urls.  
**Frontend of ESG**:  
`https://esg-frontend-service.<SOME-UNIQUE-STRING>.northeurope.azurecontainerapps.io/`  
**ESGs Organization and Department endpoints**:    
`https://esg-organization-module.<SOME-UNIQUE-STRING>.northeurope.azurecontainerapps.io`  
**ESG Reporting endpoints**:  
`https://esg-reporting-manager.<SOME-UNIQUE-STRING>.northeurope.azurecontainerapps.io`  
**Carbon Accounting endpoints**:  
`https://carbacc-taskmanagement-service.<SOME-UNIQUE-STRING>.northeurope.azurecontainerapps.io`

# 2 Create User
To interact with the endpoints, it's essential to create a system user with the appropriate privileges.  
Follow these steps to create a system user with all priveliged required throughout this guide.  
You must have admin-level access to perform these actions. Ask your administrators for such access. 
1. Navigate to the ESG application using the following URL:  `https://esg-frontend-service.<SOME-UNIQUE-STRING>.northeurope.azurecontainerapps.io/`.   
3. Login with the admin user.
4. Go to the User management tab in the left hand side of the side.
5. Create a user with the required privileges. Access to all of the endpoints in this guide will need the `Admin` and `Carbon` role.  
**Note**: Make sure you have access to the email of the user as you'll need to verify the user through an email verification flow.  
6. Save the credentials for the user. You will need that for the rest of the guide.

# 3 Create organization and department entities.
For this part we will need the following url:
`https://esg-organization-module.<SOME-UNIQUE-STRING>.northeurope.azurecontainerapps.io`
Swagger docs are available at `/docs`.

Let's start getting an access token 
```python
import json
import requests

SOME_UNIQUE_STRING = ""
esg_base_url = f"https://esg-organization-module.{SOME_UNIQUE_STRING}.northeurope.azurecontainerapps.io"

# Authenticate
token_url = f'{esg_base_url}/token'
headers = {
    'accept': 'application/json',
    'Content-Type': 'application/x-www-form-urlencoded'
}
data = {
    'username': '<YOUR USER EMAIL>',
    'password': '<YOUR PASSWORD>',
}
response = requests.post(token_url, headers=headers, data=data)
json_data = response.json()
# And finally, get the token.
token = json_data['access_token']
```

Let's start listing all existing organizations.
```python
get_organizations_url = f'{esg_base_url}/get-organizations'
headers = {
    'accept': 'application/json',
    'Authorization': f'Bearer {token}'
}
response = requests.get(get_organizations_url, headers=headers)
data = response.json()
print(data)
```

Data in the code snippet returns a list of all existing orgnizations. 
To see the departments of a given organization grab an orgniazationId and put it into the URL below:
```python
get_departments_url = f'{esg_base_url}/get-departments/{organizationId}'
```

Now let's try create an organization
```python
create_organizations_url = f'{esg_base_url}/create-organization'
headers = {
    'accept': 'application/json',
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

data = {
    'name': 'DemoOrg',
    'description': 'This org is for demo purposes'
}

response = requests.post(create_organizations_url, headers=headers, json=data)

# If successfull you can now get the organizationsId from the organization you just created.
organization_id = response.json()["organizationId"]
```

You can now go create a department within that organization with that organization id.
To create a department you will also need the uuid of the user that would be the main responsible of that department.
A main responsible is the user that automatically will be asked to fill out surveys forwarded to that department. 
So let's start listing all the users and their ids
```python
get_users_url = f'{esg_base_url}/user-list'
headers = {
    'accept': 'application/json',
    'Authorization': f'Bearer {token}'  # Replace <token> with the actual token value
}
response = requests.get(get_users_url, headers=headers)
data = response.json()
# Pick the id of the user you want to set as main responsible
main_user_id = "" # Example of a UUID for users.
# Create department
create_department_url = f'{esg_base_url}/create-department'
headers = {
    'accept': 'application/json',
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}
data = {
    "name": "DemoDepartment",
    "description": "I am a demo department. We test the demo versions of computer games",
    "organizationId": organization_id,
    "mainResponsible": main_user_id
}

response = requests.post(create_department_url, headers=headers, json=data)
# If everything went well you'll get a status code == 200.
# You can get the information of the ressource you just created.
# For instance, get the department id as follows:
department_id = response.json()["departmentId"]
```

You can modify the department by referring to it's department id.
E.g. update the departments name by the following code block:
```python
modify_department_url = f'{esg_base_url}/modify-department/{department_id}'

headers = {
    'accept': 'application/json',
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

data = {
    "name": "DemoMyApp"
}

response = requests.patch(modify_department_url, headers=headers, json=data)
```

Which means that now the name of the department has changed to DemoMyApp
You can do the same to organizations. Go to `f'{esg_base_url}/docs'` for more information.

Deleting organizations. 
Deleting is very simple. However, you need to be cautious before deleting organizations deparmtnet.
**Important** Note, you cannot delete a department or organizations that has surveys linked to it.
Those surveys needs to be removed first before the department or organization can be deleted.
Deleted surveys cannot be recovered. Therefore you should do this with caution.
The deletions endpoints are served at `/delete-organization/{organizationId}` and `/delete-organization/{departmentId}`. Please go to `f'{esg_base_url}/docs'` for more information.


# 4. Activities in Carbon.
For this part we will need the following url:
`https://carbacc-taskmanagement-service.<SOME-UNIQUE-STRING>.northeurope.azurecontainerapps.io`
Swagger docs are available at `/swagger/index.html`.

```python
SOME_UNIQUE_STRING = ""
carbon_base_url = f"https://carbacc-taskmanagement-service.{SOME_UNIQUE_STRING}.northeurope.azurecontainerapps.io"

# Authenticate
token_url = f'{carbon_base_url}/token'
user_info =  {'userName': 'test@solitwork.com',
              'password': 'swpassword'
              }
# Get token
response = requests.post(token_url, params=user_info)
json_data = response.json()
token = json_data['access_token']


# Let's start listing all activities 
endpoint_url = f'{carbon_base_url}/activities'
headers = {
    'accept': 'application/json',
    'Authorization': f'Bearer {token}'
}
# Request the data
response = requests.get(endpoint_url, headers=headers)
data = response.json()
activities = data["activities"]
```

Now that we have seen how to list all activities, let's try creating some.
Before we begin note the following:
- `Source` is the name of the source system where the activity come from. 
- `SourceID` is the unique identifier for the row in the source system. 
- `activityDate` should be formatted as `yyyy-mm-dd`.
- Each customer has 5 customAttribute fields on each activity. Below example contain the two first. However, you could easily add `customAttribute3`, `customAttribute4` and `customAttribute5`.
- Use Organizations for the Organizations throughout all activities. For instance, Don't start mixing it with Department or other columns. 
- Ce sonsistent. If you use customAttribute1 for Product Information once, do always use that field for Product Information
- Use the same structure as the developer before you. If you can see other developers made a structure in the organizations as follows `<ORGANIZATION NAME>_<UNIQUE ORGANIZATION ID FROM SOURCE>` Don't start creating activities with the following structure for organizations: `<UNIQUE ORGANIZATION ID FROM SOURCE>-<ORGANIZATION NAME>`.
- Fields (besides `SourceID`) should **never** contain integers or IDs only. Moreover, if you need to add some IDs a column do this by backing it up with some text. We will keep the application easy interpretable for the user.


```python
import_activities_url = f"{carbon_base_url}/importactivities"
headers = {
    'accept': 'application/json',
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
    }

data = {
    "sourceID": "XYZ1234",
    "source": "IAmATestSource",
    "organization": "SolitworkDemo Organisation",
    "vendor": "entest",
    "amount": 9500,
    "unit": "DKK",    
    "activityDate": "2023-01-29",
    "category": "Electricity Bill",
    "comments": "Example comment that could be on the tx in source system",
    "department": "Product Success Team",
    "customAttribute1": "Denmark",
    "customAttribute2": "Power Account"
    }

response = requests.post(import_activities_url, 
                        headers=headers, 
                        data=json.dumps(data))
```

If want to create activities at scale, consider using `f'{carbon_base_url}/importactivities/batch'`.

Now let's update the activity we just created. To update an activity you'll need the source name of the activity and it's sourceID
Before you start updating activities in production, read thouroughly the later section on the possible consequences when updating activities.

```python
source = "IAmATestSource"
sourceID = "XYZ1234"

import_activities_url = f"{carbon_base_url}/importactivities/{source}/{sourceID}"
headers = {
    'accept': 'application/json',
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
    }

data = {
    "organization": "SolitworkDemo Organisation",
    "vendor": "entest",
    "amount": 9500,
    "unit": "DKK",
    "activityDate": "2023-01-29",
    "category": "Electricity Bill",
    "comments": "Example comment that could be on the tx in source system",
    "department": "Product Success Team",
    "customAttribute1": "Denmark",
    "customAttribute2": "Power Account"
    }

response = requests.put(import_activities_url, 
                        headers=headers, 
                        data=json.dumps(data))

```

Now let's delete the activity we just modified.  
Before you start deleting activities in production, read thouroughly the later section on the possible consequences when deleting activities. 

```python
sourceID = "XYZ1234"
source = "IAmATestSource"
delete_url = f'{carbon_base_url}/importactivities/{source}/{sourceID}'
headers = {
      'accept': 'application/json',
      'Authorization': f'Bearer {token}'
  }
requests.delete(delete_url,
                headers=headers)

```
Now the activity should be deleted. 

# 5. Consequenses deleting and updating activities.
The consequences of deleting and updating activities depends on whether or not the activities has been tagged either manually or with rules.
## 5.1 Manually Tagged: 
In case you update or delete a transaction that has been manually tagged you won't be able to recall it for that given transaction afterwards.  
E.g., if a customer wants to flush a source and load it in again, manual tags will be lost forever. It's therefore very important that in scenarios where customers wants to update or delete activities that you ensure that they are aware that they will lose their manual tags for those activies.  
## 5.2 Tagged By Accounting Rules:
In cases where the updated and deleted activities are tagged by accounting rules (or exclusion rules) the tag will persist unless the activity are modified in some of the fields that makes it eligible for the given rule.  
**Example 1**: if you delete an activity and load in the excact same activity it will get the same tag.  
**Example 2**: If you delete a transaction and you change one of it's fields it will get the same tag if and only if the changed fields doesnt imply that it is now hit by another rule.  
**Example 3**: If you update an activity it will get the same tag if and only if the changed fields doesnt imply that it is now hit by another rule.


# 6. Reporting purposes
The next part of the introduction is about how you can pull the data from apis.  
This is the intended usage for any kind of reporting, no matter if it's for power bi or any storage technology you will use.  
See below what apis you should pull to get what data.  
| # | URL                                                      | Description                                                                                                   | Docs                 |
|---|----------------------------------------------------------|---------------------------------------------------------------------------------------------------------------|----------------------|
| 1 | `https://{...carbacc-taskmanagement-service...}/activitiesexport` | All tagged, autotagged and excluded activities.                                                               | `/swagger/index.html` |
| 2 | `https://{...carbacc-taskmanagement-service...}/accountingrules` | All accounting rules. Accounting rules generate the autotags. Use in comparison with importactivities        | `/swagger/index.html` |
| 3 | `https://{...carbacc-taskmanagement-service...}/filterrules` | All exclusion rules. Exclusion rules are responsible for excluded activities. Use in comparison with importactivities | `/swagger/index.html` |
| 4 | `https://{...carbacc-taskmanagement-service...}/emissionfactorsexport` | All Emission factors applied by any tag or accounting rule.                                                  | `/swagger/index.html` |
| 5 | `https://{...esg-reporting-manager...}/get-surveys` | Get all completed surveys.                                                                                    | `/docs`              |
| 6 | `https://{...esg-reporting-manager...}/get-inputs` | Get all inputs from the surveys                                                                               | `/docs`              |
| 7 | `https://{...esg-reporting-manager...}/get-figures` | Get all figures from the surveys                                                                              | `/docs`              |
| 8 | `https://{...esg-reporting-manager...}/get-units` | Get all units inputted                                                                                        | `/docs`              |
| 9 | `https://{...esg-reporting-manager...}/get-organization` | Get all organizations                                                                                         | `/docs`              |
| 10 | `https://{...esg-reporting-manager...}/get-departments` | Get all departments                                                                                           | `/docs`              |
