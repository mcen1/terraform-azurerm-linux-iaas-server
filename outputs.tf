output "instance_ip_addr" {
  value       = azurerm_network_interface.lnx_nic.private_ip_address
  description = "VM IP address"
}
