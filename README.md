# PiLab - Automated Raspberry Pi Homelab with Docker

An autonomous system for Raspberry Pi that implements Docker services and provides configuration access through a hotspot when there's no Internet connection.

## 📋 Table of Contents
- [Project Description](#-project-description)
- [Key Features](#-key-features)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Network Logging](#-network-logging)
- [Web Interface (Optional)](#-web-interface-optional)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

## 🚀 Project Description
Autonomous system for Raspberry Pi that:
1. Automatically detects Internet connection (Ethernet/WiFi)
2. Starts Docker services (Traefik, DNS, Web Server, DB) when connected
3. Activates configurable WiFi hotspot when disconnected
4. Logs network configurations for auditing
5. Provides basic web interface for configuration

## 🌟 Key Features
- ✔️ Automatic network connection detection
- ✔️ Docker Compose with isolated network
- ✔️ Auto-configuring WiFi hotspot (192.168.50.1)
- ✔️ Automatic network configuration logging
- ✔️ Automatic recovery system

## 📥 Installation

### Prerequisites
- Raspberry Pi 4/5 with Raspberry Pi OS Lite (64-bit)
- SSH access enabled
- At least 2GB RAM recommended

### Initial Steps

```bash
# Update system
sudo apt update && sudo apt full-upgrade -y

# Install dependencies
sudo apt install -y git docker.io docker-compose hostapd dnsmasq iw net-tools nmap

# Clone repository
git clone https://github.com/terrerovgh/pilab.git
cd pilab

# Run installation script
sudo ./install.sh
```
