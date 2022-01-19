# variables.tf
# Variable declarations

variable "rg" {
  type        = string
  default     = ""
  description = "Resource group where to put the VM. Must pre-exist, and all resources in resource group must be in same geographic location."
}

variable "vnet_name" {
  type        = string
  default     = ""
  description = "VNet where to put the VM. Must pre-exist, and must be in the same geographic location as the parent resource group (rg)."
}

variable "lnx_vm_name" {
  type        = string
  default     = ""
  description = "Name of the VM"
}

variable "lnx_vm_description" {
  type        = string
  default     = ""
  description = "Purpose of this VM"
}

variable "vm_size" {
  type        = string
  default     = ""
  description = "VM Size according to Azure VM sizing chart"
}

variable "vm_image_publisher" {
  type        = string
  default     = ""
  description = "VM image publisher. Options include OpenLogic, Oracle, and RedHat"
}

variable "vm_image_sku" {
  type        = string
  default     = ""
  description = "VM image SKU (see documentation for options)"
}

variable "vm_image_offer" {
  type        = string
  default     = ""
  description = "VM image offer (see documentation for options)"
}

variable "vm_image_version" {
  type        = string
  default     = "latest"
  description = "VM image version"
}

variable "lnx_subnet_name" {
  type        = string
  default     = ""
  description = "Name of the subnet"
}

variable "lnx_root_username" {
  type        = string
  default     = ""
  description = "Linux root username"
}

variable "lnx_login_group" {
  type        = string
  default     = "gg-adm-gcdunix"
  description = "Active Directory group to allow login and sudo access. Must exist in AD, must have UNIX attributes."
}

variable "lnx_public_key" {
  type        = string
  default     = ""
  description = "Public key for Linux root username"
}

variable "puppet_platform" {
  type        = string
  default     = ""
  description = "Platform associated with server. See GCD_controlrepo and GSC_controlrepo in internal github for more info."
}

variable "puppet_org" {
  type        = string
  default     = "gcd"
  description = "Either gsc or gcd."
}

variable "ansible_options" {
  type        = string
  default     = ""
  description = "Additional options for ansible such as -vvv."
}

variable "zabbix_templates" {
  type        = string
  default     = "Template_SW_Linux"
  description = "Zabbix template to use."
}

variable "zabbix_hostgroups" {
  type        = string
  default     = "Linux Non PROD - Low,Linux Servers - All"
  description = "Zabbix hostgroups to add server to. Comma seperated."
}

variable "os_disk_storage_type" {
  type        = string
  default     = ""
  description = "Storage type for the operating system disk"
}

variable "os_disk_create_option" {
  type        = string
  default     = "FromImage"
  description = "Attach, FromImage, or Empty"
}

variable "os_disk_id" {
  type        = string
  default     = ""
  description = "The id of the OS disk, only used when os_disk_create_option is set to Attach"
}

variable "os_disk_size" {
  type        = number
  default     = 127
  description = "Size for the operating system disk"
}

variable "patch_window" {
  type        = string
  default     = "undefined"
  description = "When to patch the server on a monthly basis. For example, second Sunday at 6 AM is 2_Sunday_06:00"
}

variable "application_solution" {
  type        = string
  default     = "undefined"
  description = "The application that is meant to run on the server"
}

variable "domain_name" {
  type        = string
  default     = "swazure.com"
  description = "The domain to use, typically swazure.com. No leading dots please"
}

variable "data_disk" {
  type = list(object({
    name                 = string
    storage_account_type = string
    create_option        = string
    disk_size_gb         = number
    caching              = string
    lun                  = number
  }))
  default = [
    {
      name                 = "appdisk1"
      storage_account_type = "Standard_LRS"
      create_option        = "Empty"
      disk_size_gb         = 10
      caching              = "ReadWrite"
      lun                  = 2
    }
  ]
}

variable "tags" {
  default = {
    CostCenter   = "UNDEFINED"
    DMZ          = "UNDEFINED"
    Department   = "UNDEFINED"
    Division     = "UNDEFINED"
    Environment  = "UNDEFINED"
    ManagedBy    = "Terraform"
    Owner        = "UNDEFINED | UNDEFINED@company.com"
    Program      = "UNDEFINED"
    Project      = "UNDEFINED"
    ResourceName = "UNDEFINED"
  }
  description = "Resource Tags"
}
