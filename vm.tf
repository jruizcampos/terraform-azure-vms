
# Creación de la máquina virtual de administración
resource "azurerm_linux_virtual_machine" "myVM" {
	name  = "admin"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vm_size_adm
	
    admin_username      = local.myjson.ssh_user
	admin_password		= local.myjson.ssh_password
    disable_password_authentication = false
	
	network_interface_ids = [ azurerm_network_interface.admNic.id ]

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

# Creación de las máquinas virtuales Master
resource "azurerm_linux_virtual_machine" "vmMaster" {
	count = length(var.masters)
	name  = var.masters[count.index]
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vm_size_master
	
    admin_username      = local.myjson.ssh_user
	admin_password		= local.myjson.ssh_password
    disable_password_authentication = false
	
	network_interface_ids = [ azurerm_network_interface.masterNic[count.index].id ]

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
	
	custom_data = base64encode(local.init_master)
}

# Creación de las máquinas virtuales Worker
resource "azurerm_linux_virtual_machine" "vmWorker" {
	count = length(var.workers)
	name  = var.workers[count.index]
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vm_size_worker
	
    admin_username      = local.myjson.ssh_user
	admin_password		= local.myjson.ssh_password
    disable_password_authentication = false
	
	network_interface_ids = [ azurerm_network_interface.workerNic[count.index].id ]

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
	
	custom_data = base64encode(local.init_worker)
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
