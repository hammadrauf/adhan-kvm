terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.93.0"
    }
  }
}

provider "proxmox" {
    endpoint = var.PROXMOX_VE_ENDPOINT
    username = var.PROXMOX_VE_USERNAME
    password = var.PROXMOX_VE_PASSWORD
    insecure = var.PROXMOX_VE_INSECURE
  ssh {
    agent = true
    node {  
      name    = var.proxmox_node_name
      address = var.proxmox_node_address
    }
  }
} 

module "debian13-cli" {
    source = "git::https://github.com/build-boxes/proxmox-kvm-debian13-cli.git//tfmod-proxmox-kvm-debian13-cli"
    #source = "../.."

    pub_key_file=var.pub_key_file
    pvt_key_file=var.pvt_key_file
    superuser_username=var.superuser_username
    superuser_old_password=var.superuser_old_password
    superuser_new_password=var.superuser_new_password
    root_new_password=var.root_new_password
    prefix=var.prefix

    proxmox_node_address=var.proxmox_node_address
    proxmox_node_name=var.proxmox_node_name
    proxmox_datastore_id=var.proxmox_datastore_id

    proxmox_vm_template_tags=var.proxmox_vm_template_tags
    proxmox_vm_tags=var.proxmox_vm_tags

    vm_fixed_ip=var.vm_fixed_ip
    vm_fixed_gateway=var.vm_fixed_gateway
    vm_fixed_dns=var.vm_fixed_dns
    vm_mac_address=var.vm_mac_address
    cpu_core_count=var.cpu_core_count
    memory_size=var.memory_size
    disk_size_boot=var.disk_size_boot
    disk_boot_ssd_enabled=var.disk_boot_ssd_enabled
    docker_intalled=var.docker_intalled
}

resource "null_resource" "disable_tmpfs_tmp_mount" {
  depends_on = [module.debian13-cli]
  provisioner "local-exec" {
    #interpreter = ["/bin/bash"]
    command = "ssh -o StrictHostKeyChecking=no -i ${var.pvt_key_file} ${var.superuser_username}@${module.debian13-cli.ip} 'sudo systemctl mask tmp.mount && sudo reboot'"
  }
}

resource "time_sleep" "wait_15_seconds" {
  depends_on = [null_resource.disable_tmpfs_tmp_mount]
  create_duration = "15s"
}

resource "null_resource" "wait_for_ssh_access" {
  depends_on = [time_sleep.wait_15_seconds]
  provisioner "remote-exec" {
    connection {
      target_platform = "unix"
      type            = "ssh"
      host            = module.debian13-cli.ip
      user            = var.superuser_username
      password        = var.superuser_new_password
      private_key     = file("${var.pvt_key_file}")
      agent           = false
      timeout         = "5m"
    }
    inline = [
      "echo 'Logged in OK'"
    ]
  }
}

resource "null_resource" "call_custom_script" {
  depends_on = [null_resource.wait_for_ssh_access]
  provisioner "local-exec" {
    command = <<EOT
      scp -o StrictHostKeyChecking=no -i ${var.pvt_key_file} ./scripts/install_adhan.sh ${var.superuser_username}@${module.debian13-cli.ip}:/home/${var.superuser_username}/install_adhan.sh
      ssh -o StrictHostKeyChecking=no -i ${var.pvt_key_file} ${var.superuser_username}@${module.debian13-cli.ip} "chmod +x /home/${var.superuser_username}/install_adhan.sh && /home/${var.superuser_username}/install_adhan.sh ${var.superuser_username}"
    EOT
  }
}

output "vm1_ip_address" {
  value = module.debian13-cli.ip
}

output "script_output" {
    value = null_resource.call_custom_script.*.triggers
}
