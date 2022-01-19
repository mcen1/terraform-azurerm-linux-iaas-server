# Example
```
module "terraform-azurerm-linux-iaas-server" {
  source                = "app.terraform.io/company/linux-iaas-server/azurerm"
  version               = "1.0"
  # Resource group must be in the same region as vnet (typically East US 2)
  rg                    = "MyResourceGroup1"
  # VNET name
  vnet_name             = "sb-001-vnet"
  lnx_vm_name           = "servername"
  lnx_vm_description    = "To have fun"
  vm_size               = "Standard_DS3_v2"
  vm_size            = "Standard_E2s_v3"
  vm_image_publisher = "Canonical"
  vm_image_sku       = "20.04-LTS"
  vm_image_offer     = "UbuntuServer"
  vm_image_version   = "latest"
  puppet_org            = "example"
  puppet_platform       = "GENERIC_OS_CLOUD"
  lnx_subnet_name       = "default"
  zabbix_templates      = "Template_Linux"
  zabbix_hostgroups     = "Linux Prod"
  # Cannot be root
  lnx_root_username     = "azroot"
  # Your AD group
  lnx_login_group       = "ad group name"
  # SSH key for lnx_root_username
  lnx_public_key        = "your ssh public key here"
  os_disk_storage_type  = "Standard_LRS"
  os_disk_create_option = "FromImage"
  os_disk_size          = 120
  data_disk = [{
    name                 = "appdisk1",
    storage_account_type = "Standard_LRS",
    create_option        = "Empty",
    disk_size_gb         = 10,
    caching              = "ReadWrite",
    # remember to increment if you add additional disks
    lun = 2
    } 
  ]
  # TAGS
  tags = {
    CostCenter = "",
    DMZ        = "no",
    Department = "",
    Divison    = "",
    Environment = "dev",
    Owner        = "",
    Program      = "",
    Project      = "",
    ResourceName = ""
  }
}
```

