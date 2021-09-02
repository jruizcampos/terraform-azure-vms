# Cargamos las variables de credentials.json y configuraciones de inicio
locals {
  myjson = jsondecode(file("${path.module}/credentials.json"))
  
  init_master = <<CUSTOM_DATA
#!/bin/bash
sudo yum -y install epel-release
sudo yum -y update
CUSTOM_DATA
  
  init_worker = <<CUSTOM_DATA
#!/bin/bash
sudo yum -y install epel-release
sudo yum -y update
CUSTOM_DATA
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

##### Numero de máquinas virtuales por cada tipo #####
variable "masters" {
	type = list(string)
	description = "vms master"
	#default = ["master1", "master2", "master3"]
	default = ["master1"]
}

variable "workers" {
	type = list(string)
	description = "vms workers"
	#default = ["worker1", "worker2", "worker3"]
	default = ["worker1"]
}

##### Características por cada tipo de máquina virtual #####
variable "vm_size_adm" {
  type = string
  description = "Tipo de VM de administración"
  default = "Standard_D2_v3" # 2 vCPU, 8GB RAM, 50 GB SSD
}

variable "vm_size_master" {
  type = string
  description = "Tipo de VM para Kubernetes Master"
  default = "Standard_D2_v3"
  # 2 vCPU, 8GB RAM, 50 GB SSD
}

variable "vm_size_worker" {
  type = string
  description = "Tipo de VM para Kubernetes Worker"
  default = "Standard_A2_v2"
  # 2 vCPU, 4GB RAM, 20 GB SSD
}

#####################################################
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
