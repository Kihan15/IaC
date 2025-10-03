# provider.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" 
    }
  }
}

provider "azurerm" {
  features {}
  # CRITICAL: This flag tells the azurerm provider to authenticate 
  # using the environment variables set by the 'azure/login' action.
  # These variables include the OIDC-derived access token.
  use_oidc = true 
}

# Your Terraform code for Management Group or Subscription resources
# (e.g., policy assignments, resource group creation, etc.) 
# goes into other .tf files.
