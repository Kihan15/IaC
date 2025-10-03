provider "azurerm" {
  features {}
}

provider "azapi" {
  # Required for calling Azure REST API
}

resource "azapi_resource" "subscription" {
  type      = "Microsoft.Subscription/aliases@2020-09-01"
  name      = "terraform-infra-sub"
  parent_id = var.billing_scope_id

  body = jsonencode({
    properties = {
      displayName           = "Terraform Infra Subscription"
      workload              = "Production"
      billingScopeId        = var.billing_scope_id
      subscriptionAliasName = "terraform-infra-sub"
    }
  })
}

provider "azurerm" {
  alias           = "newsub"
  subscription_id = azapi_resource.subscription.output["subscriptionId"]
  features        = {}
}

resource "azurerm_resource_group" "tfstate" {
  provider = azurerm.newsub
  name     = "tfstate-rg"
  location = "Switzerland North"
}

resource "azurerm_storage_account" "tfstate" {
  provider                = azurerm.newsub
  name                    = "tfstateaccount123"
  resource_group_name     = azurerm_resource_group.tfstate.name
  location                = azurerm_resource_group.tfstate.location
  account_tier            = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  provider              = azurerm.newsub
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
