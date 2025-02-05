#!/bin/bash

# Network check script for Raspberry Pi Homelab
# This script checks for internet connectivity and manages services accordingly

# Configuration
PING_HOST="8.8.8.8 1.1.1.1"  # Multiple hosts for redundancy
PING_COUNT=3
PING_TIMEOUT=5
LOG_DIR="/var/log/homelab/network"
HOTSPOT_SERVICE="hotspot.service"
DOCKER_SERVICE="docker-compose@homelab.service"
MAX_RETRIES=3
RETRY_DELAY=10

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Function to check internet connectivity
check_internet() {
    for host in $PING_HOST; do
        if ping -W "$PING_TIMEOUT" -c "$PING_COUNT" "$host" > /dev/null 2>&1; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Internet connection verified via $host" >> "$LOG_DIR/connectivity.log"
            return 0
        fi
    done
    echo "$(date '+%Y-%m-%d %H:%M:%S') - No internet connection available" >> "$LOG_DIR/connectivity.log"
    return 1
}

# Function to start Docker services
start_docker_services() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Internet connection detected, starting Docker services..." >> "$LOG_DIR/services.log"
    systemctl stop "$HOTSPOT_SERVICE" || true
    
    for i in $(seq 1 $MAX_RETRIES); do
        if systemctl start "$DOCKER_SERVICE"; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Docker services started successfully" >> "$LOG_DIR/services.log"
            return 0
        fi
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to start Docker services, attempt $i of $MAX_RETRIES" >> "$LOG_DIR/services.log"
        sleep "$RETRY_DELAY"
    done
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to start Docker services after $MAX_RETRIES attempts" >> "$LOG_DIR/services.log"
    return 1
}

# Function to start hotspot
start_hotspot() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - No internet connection, starting hotspot..." >> "$LOG_DIR/services.log"
    systemctl stop "$DOCKER_SERVICE" || true
    
    # Collect and log network information
    echo "Network Information - $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_DIR/network_info.log"
    ip addr show >> "$LOG_DIR/network_info.log"
    ip route show >> "$LOG_DIR/network_info.log"
    
    for i in $(seq 1 $MAX_RETRIES); do
        if systemctl start "$HOTSPOT_SERVICE"; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') - Hotspot started successfully" >> "$LOG_DIR/services.log"
            return 0
        fi
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to start hotspot, attempt $i of $MAX_RETRIES" >> "$LOG_DIR/services.log"
        sleep "$RETRY_DELAY"
    done
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Failed to start hotspot after $MAX_RETRIES attempts" >> "$LOG_DIR/services.log"
    return 1
}

# Main loop
while true; do
    if check_internet; then
        start_docker_services
    else
        start_hotspot
    fi
    sleep 60
done