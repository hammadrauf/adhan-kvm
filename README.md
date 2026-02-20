# adhan-kvm
adhan-tools Installed on Proxmox VE 9 - Debian13 KVM.

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