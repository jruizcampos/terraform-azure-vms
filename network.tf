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

# Creacion de NIC para las VMs: Empiezan como 10.10.1.20, 10.10.1.21, 10.10.1.22 ...
resource "azurerm_network_interface" "myNic" {
	count = length(var.vms)
	name                = "vmnic_${1+count.index}"
	location            = azurerm_resource_group.rg.location
	resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
		name                           = "myipconfiguration_${1+count.index}"
		subnet_id                      = azurerm_subnet.mySubnet.id 
		private_ip_address_allocation  = "Static"
		private_ip_address             = "10.0.1.${21+count.index}"
		public_ip_address_id           = azurerm_public_ip.myPublicIp[count.index].id
	}

}

# IP pública para las VMs worker:
resource "azurerm_public_ip" "myPublicIp" {
	count = length(var.vms)
	name                = "vmip_${1+count.index}"
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

# Vinculamos el security group al interface de red
resource "azurerm_network_interface_security_group_association" "mySecGroupAssociation" {
	count = length(var.vms)
    network_interface_id      = azurerm_network_interface.myNic[count.index].id
    network_security_group_id = azurerm_network_security_group.mySecGroup.id
}
