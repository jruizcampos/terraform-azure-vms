# Terraform-Azure-VMs
Proyecto Terraform para el despliegue automatizado de infraestructura Kubernetes en Microsoft Azure.

## Diagrama de red de la infraestructura a desplegar:
![diagrama de red](https://github.com/jruizcampos/terraform-azure-vms/blob/main/diagrama_de_red.jpg?raw=true)

## Archivos a personalizar
### Archivo **setup.tf**

```yaml
variable "location" {
  type = string
  description = "Región de Azure donde crearemos la infraestructura"
  # Personalizar la región por defecto
  default = "East US"
}

##### Numero de máquinas virtuales por cada tipo #####
variable "masters" {
	type = list(string)
	description = "vms master"
	# Una vm master por defecto
	default = ["master1"]
}

variable "workers" {
	type = list(string)
	description = "vms workers"
	# Personalizar el número de hosts workers por defecto
	#default = ["worker1", "worker2", "worker3"]
	default = ["worker1"]
}

##### Características por cada tipo de máquina virtual #####
variable "vm_size_adm" {
  type = string
  description = "Tipo de VM de administración"
  # Personalizar las características de la vm de administración
  # Esta vm lleva Ansible, Terraform y GIT instalados
  default = "Standard_D2_v3"    # 2 vCPU, 8GB RAM, 50 GB SSD
}

variable "vm_size_master" {
  type = string
  description = "Tipo de VM para Kubernetes Master"
  # Personalizar las características del host master
  default = "Standard_D2_v3"    # 2 vCPU, 8GB RAM, 50 GB SSD
}

variable "vm_size_worker" {
  type = string
  description = "Tipo de VM para Kubernetes Worker"
  # Personalizar las características de los hosts worker
  default = "Standard_A2_v2"    # 2 vCPU, 4GB RAM, 20 GB SSD
}
```

### Archivo **credentials.json**:

```json
{
  "subscription_id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  "client_id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  "client_secret": "XXXXXXXXXXX~XXXXXXXXXXXXXXXXXXXXXX",
  "tenant_id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
  "ssh_user": "XXXXXXXX",
  "ssh_password": "XXXXXXXXX"
}
```

Es necesario crear un archivo credentials.json en la raíz del proyecto. Copie el archivo **credentials.json.sample** como **credentials.json** y personalice los datos según lo siguiente:
- **subscription_id**: Id de subscripción de MS Azure.
- **client_id**, **client_secret** y **tenant_id**: Estos valores se obtienen al crear el Service Principal en MS Azure.
- **ssh_user** y **ssh_password**: Usuario y password que queremos tengan las máquinas virtuales Linux a desplegar.

## Pasos para el Despliegue
- Clonar el proyecto: `git clone https://github.com/jruizcampos/terraform-azure-vms.git`
Ejecutar:
- Editar los archivos setup.tf y credentials.json según lo indicado en la sección anterior.
- Realizar el despliegue con Terraform:
```bash
terraform init
terraform apply
```

