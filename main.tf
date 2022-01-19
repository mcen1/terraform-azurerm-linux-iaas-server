# generate ssh key

provider "tls" {}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# data means reference as read-only, resource group must pre-exist
data "azurerm_resource_group" "lnx_rg" {
  name = var.rg
}

data "azurerm_virtual_network" "lnx_vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.lnx_rg.name
}

data "azurerm_subnet" "lnx_subnet" {
  name                 = var.lnx_subnet_name
  resource_group_name  = data.azurerm_resource_group.lnx_rg.name
  virtual_network_name = data.azurerm_virtual_network.lnx_vnet.name
}

# resource means create
resource "azurerm_network_interface" "lnx_nic" {
  name                = "${var.lnx_vm_name}-nic"
  location            = data.azurerm_resource_group.lnx_rg.location
  resource_group_name = data.azurerm_resource_group.lnx_rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "${var.lnx_vm_name}config1"
    subnet_id                     = data.azurerm_subnet.lnx_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "lnx_vm" {
  name                = var.lnx_vm_name
  resource_group_name = data.azurerm_resource_group.lnx_rg.name
  location            = data.azurerm_resource_group.lnx_rg.location
  size                = var.vm_size
  admin_username      = var.lnx_root_username
  tags                = var.tags
  network_interface_ids = [
    azurerm_network_interface.lnx_nic.id,
  ]

  admin_ssh_key {
    username   = var.lnx_root_username
    public_key = var.lnx_public_key != "" ? chomp(tls_private_key.ssh.public_key_openssh) : "ssh-rsa snip"
  }

  os_disk {
    name                 = "${var.lnx_vm_name}osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_type
    disk_size_gb         = var.os_disk_size
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }
}

resource "null_resource" "curl_put" {
  depends_on = [
    azurerm_linux_virtual_machine.lnx_vm,
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/postdeploy.py '${var.lnx_vm_name}' '${azurerm_network_interface.lnx_nic.private_ip_address}' '${var.tags.Environment}' '${var.zabbix_templates}' '${var.puppet_org}' '${var.puppet_platform}' '${var.lnx_root_username}' '${var.lnx_login_group}' '${data.azurerm_resource_group.lnx_rg.location}' '${data.azurerm_resource_group.lnx_rg.name}' '${var.patch_window}' '${var.application_solution}' '${var.domain_name}'"
  }
}

resource "null_resource" "concat_ssh_key" {
  depends_on = [azurerm_linux_virtual_machine.lnx_vm]
  connection {
    type        = "ssh"
    host        = azurerm_network_interface.lnx_nic.private_ip_address
    private_key = tls_private_key.ssh.private_key_pem
    user        = var.lnx_root_username
  }
  provisioner "remote-exec" {
    inline     = ["echo '${var.lnx_public_key}' >> ~/.ssh/authorized_keys; echo 'ssh-rsa snip' >> ~/.ssh/authorized_keys "]
    on_failure = continue
  }
}

resource "null_resource" "run_ansible_playbook" {
  depends_on = [
    null_resource.concat_ssh_key,
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    environment = {
      SUPER_SECRET = chomp(tls_private_key.ssh.private_key_pem)
    }

    command = "echo \"$SUPER_SECRET\">temporarysshkey ; chmod go-rwx temporarysshkey; myrandom=$(echo $RANDOM $(date) | md5sum | head -c 20); echo [servers]>inventory$myrandom.ini; echo ${azurerm_network_interface.lnx_nic.private_ip_address} >> inventory$myrandom.ini; ansible-playbook ${var.ansible_options} -u ${var.lnx_root_username} --private-key temporarysshkey -i inventory$myrandom.ini playbook.yaml;/bin/true "
  }
}


resource "azurerm_managed_disk" "vm_managed_disk" {
  for_each = {
    for disk in var.data_disk : disk.name => disk
  }
  name                 = "${var.lnx_vm_name}datadisk${each.value.name}"
  location             = data.azurerm_resource_group.lnx_rg.location
  resource_group_name  = data.azurerm_resource_group.lnx_rg.name
  storage_account_type = each.value.storage_account_type
  create_option        = each.value.create_option
  disk_size_gb         = each.value.disk_size_gb
  tags                 = var.tags
  depends_on           = [azurerm_linux_virtual_machine.lnx_vm]
}

resource "azurerm_virtual_machine_data_disk_attachment" "vm_data_disk" {
  for_each = {
    for disk in var.data_disk : disk.name => disk
  }
  lun                = each.value.lun
  caching            = each.value.caching
  managed_disk_id    = azurerm_managed_disk.vm_managed_disk[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.lnx_vm.id
  depends_on = [
    azurerm_linux_virtual_machine.lnx_vm,
    azurerm_managed_disk.vm_managed_disk
  ]
}


