#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt install build-essential -y

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Configure Homebrew
echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Brew doctor
brew doctor

# Install GCC
brew install gcc

# Install Cockpit
. /etc/os-release
echo ${VERSION_CODENAME}
sudo apt install -t ${VERSION_CODENAME}-backports cockpit -y

# Setup 45drives repo
curl -sSL https://repo.45drives.com/setup | sudo bash

# Install Cockpit packages
sudo apt-get install cockpit-file-sharing cockpit-identities -y

# Install dependencies
sudo apt install ffmpeg -y

# Install NVIDIA GPU drivers
if lspci | grep -i nvidia; then
  echo "Nvidia GPU detected"
  sudo apt update
  sudo apt install nvidia-driver-515 nvidia-dkms-515 nvidia-smi -y
else
  echo "Nvidia GPU not detected"
fi

# Install AMD GPU drivers
if lspci | grep -i amd; then
  echo "AMD GPU detected"
  sudo apt update
  wget https://repo.radeon.com/amdgpu-install/22.40.5/ubuntu/jammy/amdgpu-install_5.4.50405-1_all.deb
  sudo chmod +x amdgpu-install_5.4.50405-1_all.deb
  sudo apt install ./amdgpu-install_5.4.50405-1_all.deb -y
  sudo amdgpu-install --usecase=rocm -y --accept-eula --no-32
  sudo apt install vainfo radeontop docker-compose libgl1-mesa-glx libgl1-mesa-dri xserver-xorg-video-amdgpu -y
  sudo usermod -a -G video $LOGNAME
  sudo usermod -a -G render $LOGNAME
else
  echo "AMD GPU not detected"
fi

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install NFS packages
sudo apt install nfs-utils nfs-common -y

# Install CasaOS
curl -fsSL https://get.casaos.io | sudo bash

# Register app stores in CasaOS
casaos-cli app-management register app-store https://github.com/IceWhaleTech/_appstore/archive/refs/heads/main.zip
sleep 6
casaos-cli app-management register app-store https://casaos-appstore.paodayag.dev/linuxserver.zip
sleep 6
casaos-cli app-management register app-store https://play.cuse.eu.org/Cp0204-AppStore-Play.zip
sleep 6
casaos-cli app-management register app-store https://casaos-appstore.paodayag.dev/coolstore.zip
sleep 6
casaos-cli app-management register app-store https://paodayag.dev/casaos-appstore-edge.zip
sleep 6
casaos-cli app-management register app-store https://github.com/mr-manuel/CasaOS-HomeAutomation-AppStore/archive/refs/tags/latest.zip
sleep 6
casaos-cli app-management register app-store https://github.com/bigbeartechworld/big-bear-casaos/archive/refs/heads/master.zip
sleep 6
casaos-cli app-management register app-store https://github.com/mariosemes/CasaOS-TMCstore/archive/refs/heads/main.zip
sleep 6
casaos-cli app-management register app-store https://github.com/mariosemes/CasaOS-TMCstore/archive/refs/heads/main.zip
sleep 6
casaos-cli app-management register app-store https://github.com/arch3rPro/Pentest-Docker/archive/refs/heads/master.zip
sleep 6
casaos-cli app-management register app-store https://github.com/tigerinus/yet-another-casaos-appstore/archive/refs/heads/main.zip
sleep 6
casaos-cli app-management register app-store https://github.com/cloudrack-ca/Cloudrack-CasaOS-App-Repo/archive/refs/heads/master.zip
sleep 6
casaos-cli app-management register app-store http://104.234.11.251/CasaOS-Custom-AppStore.zip
sleep 6
casaos-cli app-management register app-store https://github.com/Double-A-92/CasaOS-AppStore/archive/refs/heads/main.zip

# Restart CasaOS App Management
sudo systemctl restart casaos-app-management.service

# Print URLs
echo "Installation comlpete"
echo "CasaOS URL is http://$(hostname -I | cut -d' ' -f1)":80
echo "CasaOS URL is http://$(hostname -I | cut -d' ' -f1)":9090
