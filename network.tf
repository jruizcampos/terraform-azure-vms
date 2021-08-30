# Creación de red para la Infraestructura
resource "azurerm_virtual_network" "myNet" {
    name                = "mynet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

# Creación de Subnet:
resource "azurerm_subnet" "mySubnet" {
    name                   = "mysubnet"
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.myNet.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Creación de NIC para la VM de administración
resource "azurerm_network_interface" "admNic" {
	name                = "vmnic_adm"
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
		name                           = "ipconfiguration_adm"
		subnet_id                      = azurerm_subnet.mySubnet.id 
		private_ip_address_allocation  = "Static"
		private_ip_address             = "10.0.1.10"
		public_ip_address_id           = azurerm_public_ip.publicIpAdm.id
	}
}

# Creacion de NIC para las VMs Master: Empiezan como 10.10.1.21, 10.10.1.22, 10.10.1.23 ...
resource "azurerm_network_interface" "masterNic" {
	count = length(var.masters)
	name                = "vmnic_master${1+count.index}"
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
		name                           = "ipconfiguration_master${1+count.index}"
		subnet_id                      = azurerm_subnet.mySubnet.id
		private_ip_address_allocation  = "Static"
		private_ip_address             = "10.0.1.${21+count.index}"
		public_ip_address_id           = azurerm_public_ip.publicIpMaster[count.index].id
	}
}

# Creacion de NIC para las VMs Worker: Empiezan como 10.10.1.51, 10.10.1.52, 10.10.1.53 ...
resource "azurerm_network_interface" "workerNic" {
	count = length(var.workers)
	name                = "vmnic_worker${1+count.index}"
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
		name                           = "ipconfiguration_worker${1+count.index}"
		subnet_id                      = azurerm_subnet.mySubnet.id
		private_ip_address_allocation  = "Static"
		private_ip_address             = "10.0.1.${51+count.index}"
		public_ip_address_id           = azurerm_public_ip.publicIpWorker[count.index].id
	}
}

# IP pública para la VM de administración:
resource "azurerm_public_ip" "publicIpAdm" {
	name                = "ip_adm"
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name
	allocation_method   = "Dynamic"
	sku                 = "Basic"
}

# IP pública para las VMs Masters:
resource "azurerm_public_ip" "publicIpMaster" {
	count = length(var.masters)
	name                = "ip_master${1+count.index}"
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name
	allocation_method   = "Dynamic"
	sku                 = "Basic"
}

# IP pública para las VMs Workers:
resource "azurerm_public_ip" "publicIpWorker" {
	count = length(var.workers)
	name                = "ip_worker${1+count.index}"
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name
	allocation_method   = "Dynamic"
	sku                 = "Basic"
}

resource "azurerm_network_security_group" "mySecGroup" {
    name                = "sshtraffic"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

# Vinculamos el security group al interface de red: Admin
resource "azurerm_network_interface_security_group_association" "secGroupAssociationAdm" {
    network_interface_id      = azurerm_network_interface.admNic.id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id
}

# Vinculamos el security group al interface de red: Masters
resource "azurerm_network_interface_security_group_association" "secGroupAssociationMaster" {
	count = length(var.masters)
    network_interface_id      = azurerm_network_interface.masterNic[count.index].id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id
}

# Vinculamos el security group al interface de red: Workers
resource "azurerm_network_interface_security_group_association" "secGroupAssociationWorker" {
	count = length(var.workers)
    network_interface_id      = azurerm_network_interface.workerNic[count.index].id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id
}
