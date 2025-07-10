terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.50"
    }
  }
  required_version = ">= 1.0"
}

provider "proxmox" {
  endpoint = var.proxmox_api_url
  api_token = "${var.proxmox_api_token_id}=${var.proxmox_api_token_secret}"
  insecure = true
}

resource "proxmox_virtual_environment_vm" "ubuntu_vm" {
  count = var.vm_count
  
  name        = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  node_name   = var.proxmox_node
  vm_id       = 200 + count.index
  
  clone {
    vm_id = 5000
  }
  
  agent {
    enabled = true
  }
  
  cpu {
    cores = var.vm_cores
    type  = "host"
  }
  
  memory {
    dedicated = var.vm_memory
  }
  
  bios = "seabios"
  
  network_device {
    bridge = var.vm_network_bridge
    model  = "virtio"
  }

  disk {
    datastore_id = var.proxmox_storage_pool
    interface    = "virtio0"
    size         = parseint(replace(var.vm_disk_size, "G", ""), 10)
    ssd          = true
    discard      = "on"
    cache        = "none"
  }

  initialization {
    user_account {
      username = var.vm_user
      password = var.vm_password
      keys     = [file(var.ssh_public_key_path)]
    }
    
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  lifecycle {
    ignore_changes = [
      network_device,
    ]
  }
}

output "vm_info" {
  description = "Information about the created VMs"
  value = {
    for vm in proxmox_virtual_environment_vm.ubuntu_vm : vm.name => {
      id = vm.id
      name = vm.name
      node = vm.node_name
    }
  }
}