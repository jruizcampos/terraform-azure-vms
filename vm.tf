# Creación de una máquina virtual

resource "azurerm_linux_virtual_machine" "myVM" {
	count = length(var.vms)
	name  = var.vms[count.index]
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vm_size
	
    admin_username      = local.myjson.ssh_user
	admin_password		= local.myjson.ssh_password
    disable_password_authentication = false
	
	network_interface_ids = [ azurerm_network_interface.myNic[count.index].id ]

    #admin_ssh_key {
    #    username   = var.ssh_user
    #    public_key = file(var.public_key_path)
    #}

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
		publisher = "OpenLogic"
		offer	  = "CentOS"
		sku		  = "8_4"
		version	  = "8.4.2021071900"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.storageAcc.primary_blob_endpoint
    }
	
	custom_data = base64encode(file("cloud_init.yaml"))
	
}

resource "azurerm_resource_group" "rg" {
    name     = var.resource_group
    location = var.location
}

resource "azurerm_storage_account" "storageAcc" {
    name                     = var.resource_group
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"
}

