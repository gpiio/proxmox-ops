variable "proxmox_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "pve"
}

variable "proxmox_storage_pool" {
  description = "Proxmox storage pool"
  type        = string
  default     = "local-lvm"
}

variable "template_name" {
  description = "Name of the Packer template to clone"
  type        = string
  default     = "ubuntu-22-04-template"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

variable "vm_name_prefix" {
  description = "Prefix for VM names"
  type        = string
  default     = "ubuntu-vm"
}

variable "vm_cores" {
  description = "Number of CPU cores for each VM"
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Amount of memory (MB) for each VM"
  type        = number
  default     = 2048
}

variable "vm_disk_size" {
  description = "Disk size for each VM"
  type        = string
  default     = "20G"
}

variable "vm_network_bridge" {
  description = "Network bridge for VMs"
  type        = string
  default     = "vmbr0"
}

variable "vm_user" {
  description = "Default user for the VMs"
  type        = string
  default     = "ubuntu"
}

variable "vm_password" {
  description = "Password for the VM user"
  type        = string
  default     = "ubuntu"
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "../keys/packer_key.pub"
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
  default     = "../keys/packer_key"
}