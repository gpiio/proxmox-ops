packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variable definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve"
}

variable "proxmox_storage_pool" {
  type    = string
  default = "local"
}

variable "proxmox_storage_pool_type" {
  type    = string
  default = "directory"
}

variable "ubuntu_iso_url" {
  type    = string
  default = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
}

variable "ubuntu_iso_checksum" {
  type    = string
  default = "9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"
}

# Load SSH public key
locals {
  ssh_public_key = file("../keys/packer_key.pub")
}

source "proxmox-iso" "ubuntu-server" {
  # Proxmox connection
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM General Settings
  vm_name              = "ubuntu-22-04-template"
  vm_id                = 5000
  template_description = "Ubuntu 22.04 LTS Server Template - Built with Packer"

  # VM OS Settings (use pre-downloaded ISO)
  iso_file     = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
  unmount_iso  = true

  # VM System Settings
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"
  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "virtio"
  }

  # VM CPU Settings
  cores = "2"

  # VM Memory Settings
  memory = "2048"

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # Boot Commands
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
    "<f10><wait>"
  ]
  boot      = "c"
  boot_wait = "10s"

  # HTTP Directory with autoinstall config
  http_directory = "http"

  # Communicator Settings
  communicator = "ssh"
  ssh_username = "packer"
  ssh_password = "packer"
  ssh_timeout = "30m"
  ssh_handshake_attempts = 20
  ssh_wait_timeout = "30m"
  
  # Task timeout settings
  task_timeout = "40m"
}

build {
  name = "ubuntu-server"
  sources = [
    "source.proxmox-iso.ubuntu-server"
  ]

  # Wait for cloud-init to finish
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }

  # System updates and essential packages
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y cloud-init qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl enable ssh"
    ]
  }

  # Configure SSH keys for both users
  provisioner "shell" {
    inline = [
      "mkdir -p /home/packer/.ssh",
      "echo '${local.ssh_public_key}' | sudo tee /home/packer/.ssh/authorized_keys",
      "sudo chown -R packer:packer /home/packer/.ssh",
      "sudo chmod 700 /home/packer/.ssh",
      "sudo chmod 600 /home/packer/.ssh/authorized_keys",
      "sudo mkdir -p /home/ubuntu/.ssh",
      "echo '${local.ssh_public_key}' | sudo tee /home/ubuntu/.ssh/authorized_keys",
      "sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh",
      "sudo chmod 700 /home/ubuntu/.ssh",
      "sudo chmod 600 /home/ubuntu/.ssh/authorized_keys"
    ]
  }

  # Add network auto-configuration service
  provisioner "shell" {
    inline = [
      "sudo tee /etc/systemd/system/auto-network.service <<EOF",
      "[Unit]",
      "Description=Auto-configure network interface",
      "After=cloud-init.service",
      "Wants=cloud-init.service",
      "",
      "[Service]",
      "Type=oneshot",
      "ExecStart=/bin/bash -c 'ip link set ens18 up && dhclient ens18'",
      "RemainAfterExit=yes",
      "",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOF",
      "sudo systemctl enable auto-network.service"
    ]
  }

  # Clean up
  provisioner "shell" {
    inline = [
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean",
      "sudo cloud-init clean",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      "bash -c 'history -c' || true"
    ]
  }
}