## DevOps Azure Infra structure Operations ##
### Infrastructure as Code Project 1 ###

Deploy a Website with a load balancer 

#### Requirements ####
Minimum requirements for this project

* Azure CLI (bash) 
* Install Terraform   : https://www.terraform.io/downloads.html
* Install Packer      : https://www.packer.io/downloads


#### Deployment Instructions ####

From Azure command interface git clone https://github.com/elipski/Udacity_DevOps_Project1

1. Create Resource group (i.e. udacity-resources)

    Navigate to Project1\terrform\test\
    Edit the file vars.tf and enter the desired default Azure location. Save.

    Run: terraform apply to create the resource group used for packer and terraform resources.
    Answer yes when prompted.

    **Important**
    Copy the Azure resource group ID after completion. It will look something like the below example. Substitute your subscription ID for *:

    > terraform import azurerm_resource_group.main /subscriptions/********-****-****-****-************/resourceGroups/udacity-resources]

    When prompted enter any number for number of VMs. This no affect on the actual numebers of VMs created.

2. Edit Packer Variables to store Azure Secrets
    Open azure secrets file in Project1\packer\az_secrets.json

    Packer authenticates with Azure using a service principal. After creating Azure service principle update the az_secrets.json file with your service principles credentials: 
    client_id, 
    client_secret,
    subscription_id

3. Deploy Packer Image 

    Naviage to Project1\packer
    From the Azure command line Execute the command:

    > packer build -var-file="az_secrets.json" demo.json

    This will take a long time.

4. Import resource group into terraform
    Navigate to Project1\terraform\production
    
    > terraform import azurerm_resource_group.main /subscriptions/71567b49-501a-405e-9390-f0615bead59f/resourceGroups/udacity-resources
    
    Edit Terraform JSON configuration file to use packer image

    Navigate to Project1\terraform\production
    Edit the file vars.tf and enter the desired default Azure location. The location should be the same location as specified in Step 1 when creating the azure resource group, and the packer image (step 2). Save. 
    
5. Validate the Terrorform deployment

    from Project\terraform\production run:

    > terraform plan -out solution.plan

    Enter the desired number of Linux VMs to create when prompted. 
    Varify there are no errors when complete.

6. Apply Terraform deployment  

    from Project\terraform\production run:
    
    >terraform apply solution.plan
    
    Varify there are no errors when complete.