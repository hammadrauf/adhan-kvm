# adhan-kvm
adhan-tools Installed on Proxmox VE 9 - Debian13 KVM.
- adhan-tools project link: [https://github.com/hammadrauf/adhan-tools](https://github.com/hammadrauf/adhan-tools)

## Usage
```
git clone https://github.com/hammadrauf/adhan-kvm.git
cd adhan-kvm
cd tf*
terraform init
OR
terraform init -upgrade
terraform plan
terraform deploy -auto-approve
```
To destroy later on use:
```
terraform destroy -auto-approve
```

## Setup of Proxmox Host Sound PCI Card - Passthrough to VM
On you proxmox Host server login as priviledged use (root) and execute the script given in folder [./proxmox_utility_scripts/configure_proxmox_vm_pci_audio_passthrough.sh](./proxmox_utility_scripts/configure_proxmox_vm_pci_audio_passthrough.sh).

```
; RUN The Following On Proxmox Host
# ./configure_proxmox_vm_pci_audio_passthrough.sh <VM-ID>
```
This will cause your VM (VM_ID) to reboot then the Proxmox Host will also reboot.  
Afterwards login via ssh to your VM (VM-ID):
```
; RUN the following on the Adhan-kvm VM manually.
cd /home/SUPERUSERNAME/adhan-tools
sudo ./uninstall.sh
sudo ./install.sh
```
Now you should hear sound from the VM via PCI Pass through to the Proxmox Host Sound Card and physical speakers.
