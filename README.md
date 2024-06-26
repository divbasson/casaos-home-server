# CasaOS Home Server

Welcome to the CasaOS Home Server GitHub Wiki! This wiki is intended to provide documentation, instructions, and additional information related to the CasaOS Home Server project.

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
    - [Installation](#installation)
    - [Configuration](#configuration)
3. [Usage](#usage)
4. [Contributing](#contributing)
5. [License](#license)

## Status:
[![Codeac](https://static.codeac.io/badges/2-710467054.svg "Codeac")](https://app.codeac.io/github/divbasson/casaos-home-server)


## Introduction

The CasaOS Home Server is a project aimed at creating a home server solution to manage and control various aspects of your smart home, including devices, automation, and more. This repository serves as the primary source for the CasaOS Home Server application.
=======
- You have administrative privileges (the ability to use `sudo`).
- You are running a compatible Linux distribution with `apt` package manager.
- Your system has an internet connection to download packages.
- You have curl installed (the ability to use `curl`).
- 
## Usage


## Getting Started

### Installation

To get started with CasaOS Home Server, you can follow these steps:

1. Clone the repository to your local machine:

   ```shell
   git clone https://github.com/divbasson/casaos-home-server.git
   
# Change directory to the project folder
cd casaos-home-server


# Install dependencies (you may need Node.js and npm)
npm install
=======
   ```bash
   ./setup.sh
   ```

5. Follow any prompts or instructions provided by the script.

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
13. Updates and upgrades your system again.
14. Installs CasaOS, an operating system for managing your home server.
15. Registers multiple app stores in CasaOS.

**Note:** Please review the script carefully to understand what it's doing before running it on your system, and ensure it is compatible with your system configuration.

### deploy_apps.sh

   ```bash
   chmod +x deploy_apps.sh
   ```

   ```bash
   ./deploy_apps.sh
   ```

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
