# main.tf

# ----------------------------------------------------
# 1. CORE AZURE PROVIDER (Implicitly uses OIDC credentials from GitHub Action)
# ----------------------------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# The default provider configuration. 
# It uses the OIDC-derived token and automatically inherits
# the permissions assigned to the Service Principal at the Management Group scope.
provider "azurerm" {
  features {}
  use_oidc = true
}

# ----------------------------------------------------
# 2. TARGETED SUBSCRIPTION PROVIDER (REQUIRED FOR SUBSCRIPTION SCOPE)
# ----------------------------------------------------
# The subscription ID provided by the user: d2c5b5b1-d8df-4dbd-ac14-d347e7ab31b0
# We define an ALIAS to ensure all resources below use this specific subscription context.
provider "azurerm" {
  features {}
  alias          = "target_sub"
  use_oidtc      = true
  subscription_id = "d2c5b5b1-d8df-4dbd-ac14-d347e7ab31b0"
}

# ----------------------------------------------------
# 3. RESOURCE GROUP CREATION (Resource at Subscription Scope)
# ----------------------------------------------------
resource "azurerm_resource_group" "example" {
  # Directs this resource creation to the specific subscription alias
  provider = azurerm.target_sub 
  
  name     = "rg-prod-app-d2c5b5b1"
  location = "East US"
  
  tags = {
    environment = "Production"
    project     = "OIDC-Demo"
  }
}

# ----------------------------------------------------
# 4. STORAGE ACCOUNT CREATION (Resource within the new Resource Group)
# ----------------------------------------------------
resource "azurerm_storage_account" "example" {
  # Directs this resource creation to the specific subscription alias
  provider                 = azurerm.target_sub 
  
  name                     = "tfmgstorageacntd2c5b5b1" # Must be globally unique and lowercase
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "Production"
  }
}

# ----------------------------------------------------
# 5. OPTIONAL: OUTPUTS
# ----------------------------------------------------
output "storage_account_endpoint" {
  description = "The primary blob endpoint of the created Storage Account."
  value       = azurerm_storage_account.example.primary_blob_endpoint
}
