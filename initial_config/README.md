Paso 1: Configuración Inicial de la Raspberry Pi
Sistema Operativo:
Usa Raspberry Pi OS Lite (64-bit) para mejor rendimiento.
sudo apt update && sudo apt full-upgrade -y
Instalar Dependencias:
sudo apt install -y git docker.io docker-compose hostapd dnsmasq iw net-tools
sudo usermod -aG docker $USER
Paso 2: Script de Verificación de Red (/usr/local/bin/network-check)

#!/bin/bash

# Verificar conexión por cable (eth0)
if ip link show eth0 | grep -q "state UP"; then
  echo "Cable conectado. Verificando internet..."
  if ping -c 3 8.8.8.8 &> /dev/null; then
    echo "Internet activo. Iniciando Docker..."
    systemctl start docker-compose@homelab
    exit 0
  fi
fi

# Verificar WiFi (wlan0)
if iw dev wlan0 link | grep -q "Connected"; then
  echo "WiFi conectado. Verificando internet..."
  if ping -c 3 8.8.8.8 &> /dev/null; then
    echo "Internet activo. Iniciando Docker..."
    systemctl start docker-compose@homelab
    exit 0
  fi
fi

# Si no hay conexión, activar hotspot
echo "Sin internet. Activando hotspot..."
systemctl start hotspot

Hacer ejecutable:

sudo chmod +x /usr/local/bin/network-check
Paso 3: Servicio Systemd para el Check de Red (/etc/systemd/system/network-check.service)

[Unit]
Description=Network Connectivity Check
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/network-check

[Install]
WantedBy=multi-user.target

Habilitar servicio:

sudo systemctl enable network-check.service

Paso 4: Configuración del Hotspot WiFi

Archivo de configuración de hostapd (/etc/hostapd/hostapd.conf):

interface=wlan0
driver=nl80211
ssid=Homelab_Config
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=TuContraseñaSegura
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

Configurar dnsmasq (/etc/dnsmasq.conf):

interface=wlan0
dhcp-range=192.168.50.100,192.168.50.200,255.255.255.0,24h
Servicio del hotspot (/etc/systemd/system/hotspot.service):

[Unit]
Description=WiFi Hotspot
After=network.target

[Service]
Type=simple
ExecStartPre=/sbin/ip link set dev wlan0 up
ExecStartPre=/sbin/ip addr add 192.168.50.1/24 dev wlan0
ExecStart=/usr/sbin/hostapd /etc/hostapd/hostapd.conf
ExecStopPost=/sbin/ip addr flush dev wlan0

[Install]
WantedBy=multi-user.target

Paso 5: Docker Compose (~/homelab/docker-compose.yml)


version: '3'

networks:
  homelab_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/24

services:
  traefik:
    image: traefik:v2.5
    networks: [homelab_net]
    ports: ["80:80", "443:443"]
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik.toml:/etc/traefik/traefik.toml

  dns-server:
    image: sameersbn/bind:latest
    networks: [homelab_net]
    volumes:
      - ./bind:/data

Habilitar servicio Docker:
sudo systemctl enable docker-compose@homelab
Paso 6: Registro de Configuraciones de Red (/opt/net-logger/net-logger.sh)


#!/bin/bash
LOG_DIR="/var/log/network"
mkdir -p $LOG_DIR

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
INTERFACE=${1:-wlan0}

# Obtener detalles de red
ip addr > $LOG_DIR/$TIMESTAMP-ip.txt
ip route > $LOG_DIR/$TIMESTAMP-route.txt
cat /etc/resolv.conf > $LOG_DIR/$TIMESTAMP-dns.txt
nmap -sn 192.168.1.0/24 > $LOG_DIR/$TIMESTAMP-devices.txt
Ejecutar al conectar a nueva red:

sudo cp net-logger.sh /opt/net-logger/
sudo chmod +x /opt/net-logger/net-logger.sh
Paso 7: Web UI para Configuración (Opcional)

Servir una interfaz web simple con Python:

sudo apt install -y python3-flask
Script Flask (~/homelab-webui/app.py):

from flask import Flask, request
import subprocess

app = Flask(__name__)

@app.route('/configure-wifi', methods=['POST'])
def configure_wifi():
    ssid = request.form['ssid']
    password = request.form['password']
    with open('/etc/wpa_supplicant/wpa_supplicant.conf', 'a') as f:
        f.write(f'\nnetwork={{\nssid="{ssid}"\npsk="{password}"\n}}\n')
    subprocess.run(['wpa_cli', '-i', 'wlan0', 'reconfigure'])
    return 'Configuración guardada!'
Notas de Uso:

Al arrancar:
Si hay internet: Todos los servicios Docker se inician.
Sin internet: Conéctate al SSID Homelab_Config y visita http://192.168.50.1 para configurar.
Reiniciar servicios clave:

sudo systemctl restart network-check hotspot docker-compose@homelab
