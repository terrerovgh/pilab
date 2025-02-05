#!/bin/bash

set -e

echo "Starting PiLab installation..."

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Update system and install dependencies
echo "Updating system and installing dependencies..."
apt-get update
apt-get upgrade -y
apt-get install -y \
    docker.io \
    docker-compose \
    git \
    hostapd \
    dnsmasq \
    python3 \
    python3-pip \
    nginx

# Enable and start Docker service
systemctl enable docker
systemctl start docker

# Create project directory structure
echo "Creating project directory structure..."
mkdir -p /opt/pilab
cd /opt/pilab

# Clone the repository (assuming it's hosted on a git repository)
# git clone https://github.com/yourusername/pilab.git .

# Create necessary directories
mkdir -p config/secrets
mkdir -p config/{traefik,nginx,bind,mariadb,squid}
mkdir -p logs

# Copy example environment file
cp config/.env.example config/.env

# Generate secure passwords
echo "Generating secure passwords..."
openssl rand -base64 32 > config/secrets/db_root_password.txt

# Set proper permissions
chmod 600 config/secrets/*

# Install Python requirements
pip3 install -r requirements.txt

# Copy and enable network check service
cp initial_config/network-check.service /etc/systemd/system/
systemctl enable network-check.service
systemctl start network-check.service

# Initialize Docker Swarm (optional, for future scaling)
docker swarm init

# Start Docker services
echo "Starting Docker services..."
cd config
docker-compose up -d

echo "Installation completed successfully!"
echo "Please check the README.md file for next steps and configuration details."