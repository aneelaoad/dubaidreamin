# Attendees System - Development Workflow Document

## Purpose:

This document outlines the step-by-step process for collaborating on a Salesforce development project using Git version control and Salesforce DX (SFDX) for managing Salesforce metadata.

### Following are the prerequisite steps:
#### Step 1: Install NodeJS and Salesforce CLI 
Ensure Salesforce CLI is installed on your local machine. If not, download and install it from the official Salesforce CLI website.
#### Step 2: Create a Salesforce Project
Open your terminal or command prompt.
Navigate to the desired directory for your project.
Run the following command to create a new Salesforce project:
```
sfdx force:project:create -n YourProjectName
```
#### Step 3: Navigate to the Project Directory
Change into the newly created project directory using the ```cd``` command:
```
cd YourProjectName
```
#### Step 4: Initialize a Git Repository
Run the following commands to initialize a Git repository for version control:
```
git init
```
#### Step 5: Add a Remote Repository
Create a new repository on a platform like GitHub, GitLab, or Bitbucket. In our case it is the GitLab.
Copy the repository URL. In our case: ```https://gitlab.com/cloud1.developer/dubai-dreamin.git ```. 
Run the following command to add the remote repository:
```
git remote add origin https://gitlab.com/cloud1.developer/dubai-dreamin.git
```
## Following are the main steps
### Step 1: Create a Pull from the Remote Branch 'develop'
1. Open your terminal or command prompt.
2. Navigate to your local repository using the cd command.
3. Run the following command to pull the latest changes from the 'develop' branch:
 ```
git pull origin develop
```

### Step 2: Create Feature Branch (e.g., AXX-Datamodel)
Run the following command to create a new feature branch:
```
git checkout -b AXX-Datamodel
```
### Step 3: Authorize the Dev Hub and Create Scratch Org
Login in to your org and enable Dev Hub. Ensure Salesforce CLI is installed. You can authorize through the VS Code or
Authorize the Dev Hub using the following command:
```
sfdx force:auth:web:login
```
Create a new scratch org using the following command:
``` 
sf org create scratch --definition-file config/project-scratch-def.json --alias MyScratchOrg --set-default --target-dev-hub MyHub
```

### Step 4: Start Working on the Scratch Org
Begin your assigned ticket development here. Commence work on the designated task to contribute to the project's progress. Utilize this space to implement changes and enhancements aligned with your assigned ticket. Foster collaboration and streamline development processes effectively. Ensure regular updates and communication on your progress.

### Step 5: Retrieve Changes from Scratch Org and Push to Feature Branch
Retrieve changes from the scratch org using the following command:
```
sf project deploy start
```
Ensure there are no conflicts and resolve if any.
Commit the changes to your feature branch using Git commands:
```
git add .
git commit -m "Description of changes made in the scratch org"
git push origin AXX-Datamodel
```