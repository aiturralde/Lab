# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}


# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "rg" {
    name     = "LaboratorioTerraform"
    location = "eastus"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create virtual network
resource "azurerm_virtual_network" "vNet" {
    name                = "myVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = "Terraform Demo"
    }
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
    name                 = "mySubnet"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vNet.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    name                         = "myPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"    

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_security_group" "nsg" {  //Here defined the network secrity group
  name                = "mindcracknsg"  
  location            = "eastus"  
  resource_group_name = azurerm_resource_group.rg.name
    
  security_rule {   //Here opened remote desktop port
    name                       = "RDP"  
    priority                   = 110  
    direction                  = "Inbound"  
    access                     = "Allow"  
    protocol                   = "Tcp"  
    source_port_range          = "*"  
    destination_port_range     = "3389"  
    source_address_prefix      = "*"  
    destination_address_prefix = "*"  
  }  
} 

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "myNIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "myNicConfiguration"
        subnet_id                     = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id      = azurerm_network_interface.myterraformnic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_storage_account" "storageacc" {  //Here defined a storage account for disk
  name                     = "mindcrackstoacc"  
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = "eastus"
  account_tier             = "Standard"  
  account_replication_type = "GRS"  
}  
  
resource "azurerm_storage_container" "storagecont" {  //Here defined a storage account container for disk
  name                  = "mindcrackstoragecont"  
  #resource_group_name   = azurerm_resource_group.rg.name
  storage_account_name  = azurerm_storage_account.storageacc.name
  container_access_type = "private"  
}  
  
resource "azurerm_managed_disk" "datadisk" {  //Here defined data disk structure
  name                 = "mindcrackdatadisk"  
  location             = "eastus"
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"  
  create_option        = "Empty"  
  disk_size_gb         = "1023"    
}  

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "eastus"
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.myterraformnic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}