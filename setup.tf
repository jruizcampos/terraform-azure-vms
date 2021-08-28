# Cargamos las variables de credentials.json
locals {
  myjson = jsondecode(file("${path.module}/credentials.json"))
}

# Provider a utilizar
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.1"
    }
  }
}

# Configuramos el acceso al proveedor de Cloud
provider "azurerm" {
  features {}
  subscription_id = local.myjson.subscription_id
  client_id       = local.myjson.client_id  		# se obtiene al crear el service principal
  client_secret   = local.myjson.client_secret  	# se obtiene al crear el service principal
  tenant_id       = local.myjson.tenant_id
}

variable "location" {
  type = string
  description = "Región de Azure donde crearemos la infraestructura"
  default = "East US"
}

variable "vms" {
	type = list(string)
	description = "Lista de máquinas virtuales a crear"
	#default = ["vm1", "vm2", "vm3"]
	default = ["vm1"]
}

variable "vm_size" {
  type = string
  description = "Tipo de máquina virtual"
  default = "Standard_D2_v3" # 2 vCPU, 8GB RAM, 50 GB SSD
}

variable "resource_group" {
  type = string
  description = "Nombre para el grupo de recursos"
  default = "terraformazvms"
}

variable "public_key_path" {
  type = string
  description = "Ruta para la clave pública de acceso a las instancias"
  default = "~/.ssh/id_rsa.pub"
}
