## INSTRUCTIONS: Make a copy of this file named "dockhand.auto.tfvars" and fill in the Actual values.
##
# This is a Shadow file, illustrating what the actual file should contain.
# 
pub_key_file="/home/XXXX/.ssh/id_rsa.pub"
pvt_key_file="/home/XXXX/.ssh/id_rsa"
superuser_username="terraform"
# Password with @ symbol has issues in cloudbase-init scripts escape-sequencing in terraform ".tf" files
superuser_old_password="XXXXXXXX"
superuser_new_password="XXXXXXXX"
root_new_password="XXXXXXXX"
# prefix is actually Proxmox KVM Name, and hostname.
prefix="adhan"
# Proxmox vars
proxmox_node_address="192.168.4.20"
proxmox_node_name="pve"
PROXMOX_VE_ENDPOINT="https://192.168.4.20:8006/api2/json"
PROXMOX_VE_USERNAME="terraform-prov@pve"
PROXMOX_VE_PASSWORD="XXXXXXXX"
PROXMOX_VE_INSECURE=true
# Following specifies which datastore this VM and its artifacts will be on.
proxmox_datastore_id="local"
# Tags to identify Proxmox VM Template
proxmox_vm_template_tags=["template", "debian13", "cli", "minimal"]
# Tags to give to created VM
proxmox_vm_tags=["debian13", "cli", "adhan", "devops"]
vm_fixed_ip="192.168.0.104/24"
vm_fixed_gateway="192.168.0.1"
vm_fixed_dns=["192.168.0.1"]
vm_mac_address="DE:AD:BE:EF:01:02"
cpu_core_count=1
memory_size="850M"
disk_size_boot="8G"
disk_boot_ssd_enabled=true
docker_installed=false