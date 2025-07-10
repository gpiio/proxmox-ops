proxmox_node         = "pve"
proxmox_storage_pool = "local-lvm"

template_name = "ubuntu-22-04-template"

vm_count       = 2
vm_name_prefix = "test-ubuntu"
vm_cores       = 2
vm_memory      = 2048
vm_disk_size   = "20G"

vm_network_bridge = "vmbr0"

vm_user     = "packer"
vm_password = "packer"

ssh_public_key_path  = "../keys/packer_key.pub"
ssh_private_key_path = "../keys/packer_key"