# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0
provider "azurerm" {
  features {}
}

resource "random_pet" "prefix" {
 length = 1
}

resource "azurerm_resource_group" "default" {
  name     = "thcousin-${random_pet.prefix.id}-rg"
  location = "France Central"

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_container_registry" "default" {
  name                = "${random_pet.prefix.id}acr"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "${random_pet.prefix.id}-aks"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "${random_pet.prefix.id}-k8s"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B2s"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = "Demo"
  }
}

resource "azurerm_role_assignment" "default" {
  principal_id                     = var.appId
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.default.id
  skip_service_principal_aad_check = true
}


