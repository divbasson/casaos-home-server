# 🏡 Home Server Setup Script


This script is designed to **automate the setup of a home server environment**. It provides an easy way to install and configure **CasaOS** or **Umbrel**, two popular solutions for self-hosting applications and managing your home server. Additionally, it includes optional tools, GPU driver support, and system configurations to enhance your server's capabilities.

Whether you're setting up a personal cloud, media server, or self-hosted applications, this script simplifies the process and ensures your server is ready to go with minimal effort.

---

## 🚀 Features

### ✅ CasaOS or Umbrel Installation
- **Choose between CasaOS or Umbrel** during the setup process:
  - **CasaOS**: A sleek, modern home server solution for managing your smart home and applications.
  - **Umbrel**: A personal server OS for self-hosting applications and services.

### ✅ GPU Driver Support
- Detects **NVIDIA** or **AMD** GPUs and installs appropriate drivers.
- Configures **NVIDIA Container Toolkit** for GPU-enabled Docker containers.
- Updates the Docker `daemon.json` file to set **NVIDIA** as the default runtime.

### ✅ Docker and System Configuration
- Installs and configures **Docker** for containerized applications.
- Adds the **NVIDIA Container Runtime** to Docker for GPU acceleration.
- Updates and upgrades the system.
- Installs required dependencies (`curl`, `wget`, `git`, etc.).
- Configures logging and progress tracking.

### ✅ Optional Tools
- Prompts for the installation of additional tools like:
  - **Ollama**
  - **OpenWebUI**
  - **NVIDIA CUDA Toolkit**

### ✅ User-Friendly Features
- Provides a selection menu for choosing between CasaOS and Umbrel.
- Supports **dry-run mode** to simulate actions without making changes.
- Displays progress updates and logs all actions to a specified log file.

---

## 📋 Requirements

- **Supported OS**: Ubuntu-based distributions.
- **Required Tools**: `curl`, `wget`, `git`, `sudo`.
- **Root Privileges**: Required for system modifications.

---

## 🛠️ Usage

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/divbasson/casaos-home-server.git
cd home-server-setup
```

### 2️⃣ Make the Script Executable
```bash
chmod +x setup.sh
```

### 3️⃣ Run the Script
```bash
sudo ./setup.sh
```

### 4️⃣ Optional Flags
- `--dry-run`: Simulate the script without making changes.
- `--log-file PATH`: Specify a custom log file (default: `/var/log/homeserver_setup.log`).
- `--help`: Show help message and usage instructions.

---

## 🖥️ Installation Options

### CasaOS
A sleek, modern home server solution for managing your smart home and applications.

### Umbrel
A personal server OS for self-hosting applications and services.

---

## 🖼️ Progress Tracking

The script provides a visual progress bar to keep you informed about the installation process:

```
Progress: [██████████          ] 50% (5/10)
```

---

## ⚙️ Configuration

The script generates a default configuration file at `~/.homeserver_setup.conf` if it does not exist. You can customize the following:

- **Log File Path**: Change the default log file location.
- **CasaOS App Stores**: Add custom app store URLs.

Example configuration:
```bash
LOG_FILE="/var/log/homeserver_setup.log"
CASAOS_APP_STORES="https://my-custom-store.com/store.zip https://another-store.org/repo.zip"
```

---

## 🛡️ Disclaimer

- This script modifies your system. It is recommended to back up important data before proceeding.
- Use at your own risk. The authors are not responsible for any issues caused by running this script.

---

## 📜 License

This project is licensed under the [Unlicense](LICENSE), meaning it is free and unencumbered software released into the public domain.

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues or pull requests to improve this script.

---

## 📧 Support

If you encounter any issues or have questions, please open an issue in the repository or contact the maintainer.

---
