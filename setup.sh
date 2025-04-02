#!/bin/bash

# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Default configuration
CONFIG_FILE="${HOME}/.homeserver_setup.conf"
LOG_FILE="/var/log/homeserver_setup.log"
DRY_RUN=false
PROGRESS=0
TOTAL_STEPS=0  # Will be set based on choice

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'  # No Color
BOLD='\033[1m'

# ASCII Art for the header
HEADER_ART=$(cat << 'EOF'
   _____
  /     \
 /_______\
 |  Home | 
 | Server|
 | Setup |
 |_______|
EOF
)

# Detect the non-root user
if [[ -n "${SUDO_USER}" ]]; then
    REAL_USER="${SUDO_USER}"
else
    REAL_USER="$(whoami)"
fi

# Generate default config file if it doesn't exist
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}Config file not found at $CONFIG_FILE. Creating default configuration...${NC}"
    cat << 'EOF' > "$CONFIG_FILE"
# Custom log file path (optional)
LOG_FILE="/var/log/homeserver_setup.log"

# Custom CasaOS app store URLs (optional, space-separated)
# Uncomment and add your own URLs if desired
# CASAOS_APP_STORES="https://my-custom-store.com/store.zip https://another-store.org/repo.zip"
EOF
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✓ Default config file created at $CONFIG_FILE${NC}"
    else
        echo -e "${RED}${BOLD}✗ Failed to create config file at $CONFIG_FILE. Proceeding with defaults.${NC}"
    fi
fi

# Load config file if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    echo -e "${CYAN}Loading configuration from $CONFIG_FILE...${NC}"
    source "$CONFIG_FILE"
fi

# Parse command-line options (overrides config file)
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --log-file) LOG_FILE="$2"; shift 2 ;;
        --help|-h)
            echo -e "${BLUE}Usage: $0 [OPTIONS]${NC}"
            echo -e "${BLUE}Options:${NC}"
            echo -e "${CYAN}  --dry-run       Simulate the script without making changes${NC}"
            echo -e "${CYAN}  --log-file PATH Specify custom log file (default: $LOG_FILE)${NC}"
            echo -e "${CYAN}  --help, -h      Show this help message${NC}"
            exit 0
            ;;
        *) echo -e "${RED}${BOLD}✗ Unknown option: $1${NC}"; exit 1 ;;
    esac
done

# Set up logging
readonly LOG_FILE
if [[ ! -d "$(dirname "$LOG_FILE")" ]]; then
    mkdir -p "$(dirname "$LOG_FILE")" || { echo -e "${RED}${BOLD}✗ Cannot create log directory${NC}"; exit 1; }
fi
exec > >(tee -a "$LOG_FILE") 2>&1

# Function to update progress with a bar
update_progress() {
    PROGRESS=$((PROGRESS + 1))
    local percent=$((PROGRESS * 100 / TOTAL_STEPS))
    local bar_length=20
    local filled=$((percent * bar_length / 100))
    local empty=$((bar_length - filled))
    printf -v bar "%${filled}s" ""
    printf -v empty_space "%${empty}s" ""
    echo -e "${YELLOW}${BOLD}Progress: [${GREEN}${bar// /█}${NC}${empty_space// / }] $percent% ($PROGRESS/$TOTAL_STEPS)${NC}"
}

# Function to log and execute commands
run_cmd() {
    echo -e "${MAGENTA}Running: $*${NC}" | tee -a "$LOG_FILE"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${CYAN}[Dry Run] Would execute: $*${NC}"
    else
        "$@" || { echo -e "${RED}${BOLD}✗ Failed to execute: $*${NC}"; cleanup; exit 1; }
    fi
}

# Cleanup function for rollback
cleanup() {
    echo -e "${YELLOW}${BOLD}⚠ Cleaning up due to failure...${NC}"
    # Remove any potentially problematic CUDA repository files
    sudo rm -f /etc/apt/sources.list.d/*cuda*.list
    # Remove temporary CUDA keyring file if it exists
    sudo rm -f /tmp/cuda-keyring.deb
    echo -e "${CYAN}Removed stale CUDA repository files and temp files${NC}"
}

# Prompt for optional installations with flair
prompt_install() {
    local tool=$1
    local install_cmd=$2
    echo -e "${BLUE}${BOLD}✨ Optional Install: $tool${NC}"
    read -p "Would you like to install $tool? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Installing $tool...${NC}"
        if [[ "$tool" == "OpenWebUI" && ! "$DRY_RUN" == "true" ]]; then
            # Ensure Docker is running before OpenWebUI install
            if ! docker info >/dev/null 2>&1; then
                echo -e "${RED}${BOLD}✗ Docker is not running. Starting Docker...${NC}"
                run_cmd sudo systemctl start docker
                sleep 5  # Give Docker time to start
                if ! docker info >/dev/null 2>&1; then
                    echo -e "${RED}${BOLD}✗ Failed to start Docker. Cannot install OpenWebUI.${NC}"
                    exit 1
                fi
            fi
        fi
        eval "$install_cmd"
        # Only update progress after successful install
        update_progress
    fi
}

# CasaOS Installation Function
install_casaos() {
    echo -e "${YELLOW}${BOLD}⚠ WARNING: This script modifies your system. Back up important data first!${NC}"
    read -p "Continue? (y/n): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "${RED}Aborted by user.${NC}"; exit 0; }

    echo -e "${BLUE}${BOLD}🚀 Updating system and installing packages...${NC}"
    run_cmd sudo apt update
    run_cmd sudo apt upgrade -y
    run_cmd sudo apt install -y build-essential curl wget git sudo apt-transport-https ca-certificates software-properties-common \
        nfs-common cockpit cockpit-storaged cockpit-file-sharing cockpit-machines cockpit-navigator
    update_progress

    echo -e "${BLUE}${BOLD}🐳 Installing Docker...${NC}"
    if ! command -v docker &>/dev/null; then
        run_cmd sudo curl -fsSL https://get.docker.com | bash
        read -p "Add a user to Docker group (default: $REAL_USER): " DOCKER_USER
        DOCKER_USER=${DOCKER_USER:-$REAL_USER}
        run_cmd sudo usermod -aG docker "$DOCKER_USER"
    else
        echo -e "${GREEN}Docker already installed, skipping...${NC}"
    fi
    update_progress

    echo -e "${BLUE}${BOLD}🍺 Installing Homebrew...${NC}"
    if ! command -v brew &>/dev/null; then
        run_cmd sudo -u "$REAL_USER" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo -e "${GREEN}Homebrew already installed, skipping...${NC}"
    fi
    update_progress

    echo -e "${BLUE}${BOLD}🎮 Checking for GPU drivers...${NC}"
    if lspci | grep -i nvidia >/dev/null 2>&1; then
        echo -e "${GREEN}NVIDIA GPU detected. Determining driver version...${NC}"
        # Add NVIDIA driver PPA
        run_cmd sudo add-apt-repository -y ppa:graphics-drivers/ppa
        run_cmd sudo apt update

        # Get NVIDIA GPU model
        GPU_MODEL=$(lspci | grep -i nvidia | grep -oP '(?<=NVIDIA Corporation ).*(?= \[)') || GPU_MODEL="Unknown"
        echo -e "${CYAN}Detected GPU: $GPU_MODEL${NC}"

        # Simple logic to determine driver version based on GPU model
        if echo "$GPU_MODEL" | grep -E "RTX 30|RTX 40|A100" >/dev/null; then
            DRIVER_VERSION="550"  # Newer GPUs (Ampere, Ada Lovelace)
            echo -e "${CYAN}Selecting NVIDIA driver version $DRIVER_VERSION for modern GPUs${NC}"
        elif echo "$GPU_MODEL" | grep -E "GTX 10|RTX 20" >/dev/null; then
            DRIVER_VERSION="535"  # Turing, Pascal
            echo -e "${CYAN}Selecting NVIDIA driver version $DRIVER_VERSION for mid-range GPUs${NC}"
        else
            DRIVER_VERSION="470"  # Older GPUs (Maxwell, Kepler)
            echo -e "${CYAN}Selecting NVIDIA driver version $DRIVER_VERSION for legacy GPUs${NC}"
        fi

        # Install the selected driver version
        run_cmd sudo apt install -y "nvidia-driver-$DRIVER_VERSION" "nvidia-utils-$DRIVER_VERSION"
        if command -v nvidia-smi &>/dev/null; then
            echo -e "${GREEN}✔ NVIDIA drivers installed successfully. Version: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader)${NC}"
        else
            echo -e "${YELLOW}⚠ NVIDIA drivers installed, but nvidia-smi not found. Continuing...${NC}"
        fi

        # Install NVIDIA Container Toolkit
        echo -e "${BLUE}Installing NVIDIA Container Toolkit...${NC}"
        run_cmd sudo curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${CYAN}[Dry Run] Would configure NVIDIA Container Toolkit repository${NC}"
        else
            curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
                grep "^deb " | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list > /dev/null
            echo -e "${CYAN}NVIDIA Container Toolkit repository configured${NC}"
        fi
        run_cmd sudo apt update
        run_cmd sudo apt install -y nvidia-container-toolkit

        # Configure Docker to use NVIDIA runtime
        echo -e "${BLUE}Configuring Docker to use NVIDIA runtime...${NC}"
        DOCKER_CONFIG_FILE="/etc/docker/daemon.json"
        if [[ ! -f "$DOCKER_CONFIG_FILE" ]] || ! grep -q "nvidia" "$DOCKER_CONFIG_FILE"; then
            run_cmd sudo tee "$DOCKER_CONFIG_FILE" > /dev/null << 'EOF'
{
    "runtimes": {
        "nvidia": {
            "path": "nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
EOF
            run_cmd sudo systemctl restart docker
            echo -e "${GREEN}✔ Docker configured with NVIDIA runtime${NC}"
        else
            echo -e "${GREEN}Docker already configured with NVIDIA runtime, skipping...${NC}"
        fi

    elif lspci | grep -i amd >/dev/null 2>&1; then
        echo -e "${GREEN}AMD GPU detected. Installing drivers...${NC}"
        run_cmd sudo apt install -y firmware-amd-graphics libdrm-amdgpu1
    else
        echo -e "${YELLOW}No supported GPU detected. Skipping driver installation.${NC}"
    fi
    update_progress

    echo -e "${BLUE}${BOLD}🏡 Installing CasaOS...${NC}"
    if ! command -v casaos-cli &>/dev/null; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${CYAN}[Dry Run] Would execute: curl -fsSL https://get.casaos.io | bash${NC}"
        else
            bash -c "$(curl -fsSL https://get.casaos.io)" || {
                echo -e "${RED}${BOLD}✗ Failed to install CasaOS. Check logs or try running as a non-root user with sudo.${NC}"
                exit 1
            }
        fi
    else
        echo -e "${GREEN}CasaOS already installed, skipping...${NC}"
    fi
    update_progress

    echo -e "${BLUE}${BOLD}🛒 Registering CasaOS App Stores...${NC}"
    if command -v casaos-cli &>/dev/null; then
        declare -A app_store_urls
        app_store_urls=(
            ["https://github.com/IceWhaleTech/_appstore/archive/refs/heads/main.zip"]=""
            ["https://casaos-appstore.paodayag.dev/linuxserver.zip"]=""
            ["https://play.cuse.eu.org/Cp0204-AppStore-Play.zip"]=""
            ["https://casaos-appstore.paodayag.dev/coolstore.zip"]=""
            ["https://paodayag.dev/casaos-appstore-edge.zip"]=""
            ["https://github.com/mr-manuel/CasaOS-HomeAutomation-AppStore/archive/refs/tags/latest.zip"]=""
            ["https://github.com/bigbeartechworld/big-bear-casaos/archive/refs/heads/master.zip"]=""
            ["https://github.com/mariosemes/CasaOS-TMCstore/archive/refs/heads/main.zip"]=""
            ["https://github.com/arch3rPro/Pentest-Docker/archive/refs/heads/master.zip"]=""
            ["https://github.com/tigerinus/yet-another-casaos-appstore/archive/refs/heads/main.zip"]=""
            ["https://github.com/cloudrack-ca/Cloudrack-CasaOS-App-Repo/archive/refs/heads/master.zip"]=""
            ["http://104.234.11.251/CasaOS-Custom-AppStore.zip"]=""
            ["https://github.com/Double-A-92/CasaOS-AppStore/archive/refs/heads/main.zip"]=""
        )

        if [[ -n "${CASAOS_APP_STORES:-}" ]]; then
            for url in $CASAOS_APP_STORES; do
                app_store_urls["$url"]=""
            done
        fi

        for url in "${!app_store_urls[@]}"; do
            echo -e "${CYAN}Registering $url...${NC}"
            if [[ "$DRY_RUN" == "true" ]]; then
                echo -e "${CYAN}[Dry Run] Would register: $url${NC}"
            else
                sudo casaos-cli app-management register app-store "$url" || {
                    echo -e "${YELLOW}${BOLD}⚠ Warning: Failed to register $url, continuing...${NC}"
                }
                sleep 5
            fi
        done
        run_cmd sudo systemctl restart casaos-app-management
    else
        echo -e "${YELLOW}CasaOS CLI not found. Skipping App Store registration.${NC}"
    fi
    update_progress

    IP_ADDR=$(hostname -I | awk '{print $1}' || echo "Unknown")
    readonly IP_ADDR
    update_progress

    echo -e "${BLUE}${BOLD}🔍 Validating installations...${NC}"
    [[ "$DRY_RUN" == "false" ]] && docker ps &>/dev/null && echo -e "${GREEN}✔ Docker is running${NC}" || echo -e "${YELLOW}⚠ Docker not verified${NC}"
    [[ "$DRY_RUN" == "false" ]] && sudo systemctl is-active casaos &>/dev/null && echo -e "${GREEN}✔ CasaOS is running${NC}" || echo -e "${YELLOW}⚠ CasaOS not verified${NC}"
    update_progress

    echo -e "\n${GREEN}${BOLD}✅ CasaOS Installation Complete!${NC}"
    echo -e "${CYAN}============================${NC}"
    echo -e "${GREEN}✔ Docker: $(docker --version 2>/dev/null || echo 'Not Found')${NC}"
    echo -e "${GREEN}✔ CasaOS: $(casaos-cli --version 2>/dev/null || echo 'Not Found')${NC}"
    echo -e "${GREEN}✔ Cockpit: $(sudo dpkg -l | grep cockpit >/dev/null && echo 'Yes' || echo 'No')${NC}"
    echo -e "${GREEN}✔ GPU Drivers: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo 'No NVIDIA GPU found')${NC}"
    echo -e "${GREEN}✔ Open Ports: $(sudo ss -tulnp | grep LISTEN || echo 'Unable to retrieve')${NC}"
    echo -e "${CYAN}============================${NC}"
    echo -e "${MAGENTA}${BOLD}🎉 Access your home server:${NC}"
    echo -e "${BLUE}🔹 CasaOS → http://$IP_ADDR:80${NC}"
    echo -e "${BLUE}🔹 Cockpit → https://$IP_ADDR:9090${NC}"
    if docker ps -a | grep -q open-webui; then
        echo -e "${BLUE}🔹 OpenWebUI → http://$IP_ADDR:8080${NC}"
    fi
    echo -e "${GREEN}${BOLD}🚀 Enjoy your new home server!${NC}"
    if lspci | grep -i nvidia >/dev/null 2>&1; then
        echo -e "${YELLOW}${BOLD}ℹ NVIDIA GPU Reminder:${NC}"
        echo -e "${CYAN}To enable GPU support in Docker containers, add these environment variables:${NC}"
        echo -e "${CYAN}  - NVIDIA_VISIBLE_DEVICES=all${NC}"
        echo -e "${CYAN}  - NVIDIA_DRIVER_CAPABILITIES=compute,utility${NC}"
        echo -e "${CYAN}For example, in a docker-compose.yml:${NC}"
        echo -e "${CYAN}    environment:${NC}"
        echo -e "${CYAN}      - NVIDIA_VISIBLE_DEVICES=all${NC}"
        echo -e "${CYAN}      - NVIDIA_DRIVER_CAPABILITIES=compute,utility${NC}"
    fi
    # Move optional installs after final progress update
    prompt_install "Ollama" "sudo curl -fsSL https://ollama.com/install.sh | bash"
    prompt_install "OpenWebUI" "
        sudo mkdir -p /var/lib/open-webui &&
        sudo timeout 300 docker run -d --name open-webui \
            -p 8080:8080 \
            -v /var/lib/open-webui:/app/backend/data \
            --restart unless-stopped \
            ghcr.io/open-webui/open-webui:main
    "
    prompt_install "NVIDIA CUDA" "
        sudo wget -q https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb -O /tmp/cuda-keyring.deb &&
        sudo dpkg -i /tmp/cuda-keyring.deb &&
        sudo rm -f /tmp/cuda-keyring.deb &&
        sudo curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/3bf863cc.pub | sudo gpg --dearmor -o /usr/share/keyrings/cuda-archive-keyring.gpg || true &&
        sudo apt update &&
        sudo apt install -y cuda-toolkit
    "
}

# Umbrel Installation Function
install_umbrel() {
    echo -e "${YELLOW}${BOLD}⚠ WARNING: This script will install Umbrel and modify your system. Back up data first!${NC}"
    read -p "Continue? (y/n): " confirm
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo -e "${RED}Aborted by user.${NC}"; exit 0; }

    echo -e "${BLUE}${BOLD}🚀 Updating system...${NC}"
    run_cmd sudo apt update
    run_cmd sudo apt upgrade -y
    update_progress

    echo -e "${BLUE}${BOLD}📦 Installing Umbrel dependencies...${NC}"
    run_cmd sudo apt install -y curl
    update_progress

    echo -e "${BLUE}${BOLD}☂️ Installing Umbrel...${NC}"
    run_cmd sudo curl -L https://umbrel.sh | bash
    update_progress

    IP_ADDR=$(hostname -I | awk '{print $1}' || echo "Unknown")
    readonly IP_ADDR
    update_progress

    echo -e "\n${GREEN}${BOLD}✅ Umbrel Installation Complete!${NC}"
    echo -e "${CYAN}============================${NC}"
    echo -e "${GREEN}✔ Umbrel Installed: Check http://$IP_ADDR for access${NC}"
    echo -e "${GREEN}✔ Open Ports: $(sudo ss -tulnp | grep LISTEN || echo 'Unable to retrieve')${NC}"
    echo -e "${CYAN}============================${NC}"
    echo -e "${MAGENTA}${BOLD}🎉 Access your Umbrel dashboard:${NC}"
    echo -e "${BLUE}🔹 Umbrel → http://$IP_ADDR${NC}"
    echo -e "${GREEN}${BOLD}🚀 Enjoy your new Umbrel server!${NC}"
    update_progress

    echo -e "${YELLOW}${BOLD}ℹ Note: Umbrel may require a reboot. Run 'sudo reboot' if the dashboard isn’t accessible.${NC}"
}

# Check for required tools
for tool in curl wget git; do
    if ! command -v "$tool" &>/dev/null; then
        echo -e "${RED}${BOLD}✗ $tool is required but not installed.${NC}"
        run_cmd sudo apt install -y "$tool"
    fi
done

# Fancy Selection Menu
clear
echo -e "${YELLOW}${BOLD}${HEADER_ART}${NC}"
echo -e "${GREEN}${BOLD}Welcome to the Home Server Setup Script!${NC}"
echo -e "${CYAN}Choose your home server software:${NC}"
PS3=$(echo -e "${BLUE}${BOLD}Enter your choice (1-2): ${NC}")
options=(
    "${GREEN}Install CasaOS${NC} - A sleek, modern home server solution"
    "${MAGENTA}Install Umbrel${NC} - A personal server OS for self-hosting"
)
select opt in "${options[@]}"; do
    case $REPLY in
        1)
            echo -e "${GREEN}${BOLD}Proceeding with CasaOS installation...${NC}"
            TOTAL_STEPS=10  # Adjusted to reflect mandatory steps only
            install_casaos
            break
            ;;
        2)
            echo -e "${MAGENTA}${BOLD}Proceeding with Umbrel installation...${NC}"
            TOTAL_STEPS=5
            install_umbrel
            break
            ;;
        *)
            echo -e "${RED}${BOLD}✗ Invalid choice. Please select 1 or 2.${NC}"
            ;;
    esac
done

echo -e "${GREEN}${BOLD}✅ Setup complete! Check $LOG_FILE for details.${NC}"