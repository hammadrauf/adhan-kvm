#!/bin/bash
SUPERUSERNAME=$1
sudo apt install -y git
echo 'Running custom script...'
cd /home/${SUPERUSERNAME}
git clone https://github.com/hammadrauf/adhan-tools.git
cd adhan-tools
chmod +x *.sh
sudo ./install.sh
echo 'Custom script execution completed....'
