#!/bin/bash

# Update and upgrade system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install build-essential -y

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Configure Homebrew and set up environment
echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Check Homebrew installation
brew doctor

# Install GCC using Homebrew
brew install gcc

# Install Cockpit
source /etc/os-release
sudo apt install -t ${VERSION_CODENAME}-backports cockpit -y

# Setup 45drives repo
curl -sSL https://repo.45drives.com/setup | sudo bash

# Install Cockpit packages
sudo apt-get install cockpit-file-sharing cockpit-identities -y

# Install dependencies
sudo apt install ffmpeg -y

# Install GPU drivers
if lspci | grep -i nvidia; then
  echo "Nvidia GPU detected"
  sudo apt update
  sudo apt install nvidia-driver-515 nvidia-dkms-515 nvidia-smi -y
else
  echo "Nvidia GPU not detected"
fi

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

app_store_urls=(
  "https://github.com/IceWhaleTech/_appstore/archive/refs/heads/main.zip"
  "https://casaos-appstore.paodayag.dev/linuxserver.zip"
  "https://play.cuse.eu.org/Cp0204-AppStore-Play.zip"
  "https://casaos-appstore.paodayag.dev/coolstore.zip"
  "https://paodayag.dev/casaos-appstore-edge.zip"
  "https://github.com/mr-manuel/CasaOS-HomeAutomation-AppStore/archive/refs/tags/latest.zip"
  "https://github.com/bigbeartechworld/big-bear-casaos/archive/refs/heads/master.zip"
  "https://github.com/mariosemes/CasaOS-TMCstore/archive/refs/heads/main.zip"
  "https://github.com/mariosemes/CasaOS-TMCstore/archive/refs/heads/main.zip"
  "https://github.com/arch3rPro/Pentest-Docker/archive/refs/heads/master.zip"
  "https://github.com/tigerinus/yet-another-casaos-appstore/archive/refs/heads/main.zip"
  "https://github.com/cloudrack-ca/Cloudrack-CasaOS-App-Repo/archive/refs/heads/master.zip"
  "http://104.234.11.251/CasaOS-Custom-AppStore.zip"
  "https://github.com/Double-A-92/CasaOS-AppStore/archive/refs/heads/main.zip"
)

for app_store_url in "${app_store_urls[@]}"; do
  casaos-cli app-management register app-store "$app_store_url"
  sleep 6
done

# Restart CasaOS app management service
sudo systemctl restart casaos-app-management.service

# Display installation completion message
echo "Installation complete"
echo "CasaOS URL is http://$(hostname -I | cut -d' ' -f1):80"
echo "Cockpit URL is http://$(hostname -I | cut -d' ' -f1):9090"
