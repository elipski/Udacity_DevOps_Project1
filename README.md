## DevOps Azure Infra structure Operations ##
### Infrastructure as Code Project 1 ###
___

### Introduction ###
Deploy a Website with a load balancer using terraform, and packer templates, and the Azure CLI  

#### Dependencies ####
Minimum requirements for this project

* Azure CLI (bash) 
* Install Terraform   : https://www.terraform.io/downloads.html
* Install Packer      : https://www.packer.io/downloads

___

#### Deployment Instructions ####

1. Clone repository 

    From Azure command interface 
    > git clone https://github.com/elipski/Udacity_DevOps_Project1

2.  Navigate to Project1\vars.tf

    Implementation specific variables are stored in the vars.tf file. In this file you can set up a default value such as number of VMs to create and the Azure location to create packer and terraform resources. 

    Navigate to \Project1 and open vars.tf using your text editor of choice (vi for example). Look for the variable "location" and default setting for location. Currently it is set to eastus2. The location should be the Azure location closest to where the created VMs will be utilized by the end users. Edit the file vars.tf and enter the desired default Azure location. The location should be the same location throughout this deployment. Save. 

    ![vars](./images/varsCapture.JPG)

    Terraform Variables: https://www.terraform.io/docs/configuration/variables.html
    
2. Create Resource group (i.e. udacity-resources)

    Navigate to \Project1\create_rg and open vars.tf using your text editor of choice (vi for example). Look for the variable "location" and default setting for location. Currently it is set to eastus2. The location should be the Azure location closest to where the created VMs will be utilized by the end users. Edit the file vars.tf and enter the desired default Azure location. The location should be the same location throughout this deployment. Save. 

    Run terraform apply to create the resource group used for packer and terraform resources:

    ![apply](./images/terraformApply.JPG)

    Answer yes when prompted.

    **Important**
    Copy the Azure resource group ID after completion and save it for later use. It will look something like the below parameter. Substitute your subscription ID for where you see dashes (-) below:

    >[id=/subscriptions/- - - -/resourceGroups/udacity-resources]

    ![resource](./images/resourceGroupID.JPG)

3. Edit Packer variables to store Azure secrets unique to your Azure subscription 
    
    Navigate to \Project1 and open azure secrets file in Project1\az_secrets.json using your text editor of choice (vi for example). Look for the variables: 

    - client_id 
    - client_secret
    - subscription_id

    Packer authenticates with Azure using a service principal. After creating Azure service principle update the above variables in the az_secrets.json file with your service principles credentials. 

    ![packer vars](./images/packerVars.JPG)

4. Deploy Packer Image 

    Naviage to \Project1
    
    From the Azure command line Execute the command:

    > packer build -var-file="az_secrets.json" server.json

    ![packer build](./images/packerBuild.JPG)

    This will take a long time.

5. Import resource group into terraform 

    Navigate to \Project1 and then import the resource group ID you created earlier (in step 1). Use the resource group ID copied earlier.
    
    > terraform import azurerm_resource_group.main /subscriptions/- - - -/resourceGroups/udacity-resources

    ![Terraform Import](./images/terraformImport.JPG)
    
7. Validate the Terrorform deployment

    from \Project1 run:

    ![terrform plan](./images/terraformPlan.JPG)

    Verify there are no errors when complete.

8. Apply Terraform deployment  

    from \Project run:

    ![Terraform Apply](./images/terraformApplySolution.JPG)
    
    Answer yes when prompted.
    Verify there are no errors when complete.
