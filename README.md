# Script README

This script is intended to automate the setup and configuration of various software and packages on a Linux system. It includes the installation of development tools, Homebrew, various GPU drivers, CasaOS, and registration of multiple app stores. Before running this script, please ensure that you have the necessary permissions to execute administrative commands using `sudo`.

## Prerequisites

Before running this script, make sure your system meets the following prerequisites:

- You have administrative privileges (the ability to use `sudo`).
- You are running a compatible Linux distribution with `apt` package manager.
- Your system has an internet connection to download packages.

## Usage

1. Open a terminal on your Linux system.

2. Create a new text file (e.g., `setup.sh`) and paste the script contents into it.

3. Make the file executable using the following command:

   ```bash
   chmod +x setup.sh
   ```

4. Execute the script with the following command:

   ```bash
   ./setup.sh
   ```

5. Follow any prompts or instructions provided by the script.

6. Applications are availible at:

## Script Overview

Here's an overview of what the script does:

1. Updates and upgrades your system's package lists and installed packages.
2. Installs the `build-essential` package for development tools.
3. Installs Homebrew, a package manager for macOS and Linux.
4. Configures Homebrew for your system.
5. Runs `brew doctor` to check the Homebrew installation.
6. Installs the GCC compiler using Homebrew.
7. Installs Cockpit, a web-based server management tool.
8. Sets up the 45drives repository.
9. Installs Cockpit packages for file sharing and identities.
10. Installs FFmpeg and checks for NVIDIA GPU presence and installs appropriate drivers if found.
11. Checks for AMD GPU presence and installs appropriate drivers if found.
12. Checks for Coral Edge TPU PCIe presence and installs the required packages.
13. Updates and upgrades your system again.
14. Installs NFS utilities.
15. Searches for NFS-related packages.
16. Installs CasaOS, an operating system for managing your home server.
17. Registers multiple app stores in CasaOS.

**Note:** Please review the script carefully to understand what it's doing before running it on your system, and ensure it is compatible with your system configuration.

# README


### deploy_apps.sh

Once you have successfully executed `setup.sh`, you can proceed to run the `deploy_apps.sh` script.

The `deploy_apps.sh` script automates the process of deploying your applications using Docker Compose. It iterates through each folder in the current directory, runs `docker-compose up` in each folder, and waits for one container to complete before moving on to the next folder. This ensures that each application is correctly deployed and running before proceeding to the next one.

To run `deploy_apps.sh`, make sure you have completed the setup process by executing `setup.sh`. Then, navigate to the project directory and execute the following command:


Make sure to run `deploy_apps.sh` after `setup.sh` to ensure successful deployment of your applications.

Please note that both `setup.sh` and `deploy_apps.sh` scripts should be executable. If they are not, you can make them executable by running the following command for each script:


That's it! You should now be able to easily deploy your applications using the `deploy_apps.sh` script after running the initial setup with `setup.sh`.


## Caution

Running this script will make system-level changes, including installing and configuring software, drivers, and repositories. Make sure you have backups and are aware of the potential consequences of these actions.

The script may take some time to complete, depending on your system's performance and the speed of your internet connection.

## Disclaimer

This script is provided as-is and without any warranties. Use it at your own risk, and ensure it is appropriate for your specific system and use case.
