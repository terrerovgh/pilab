# Configuración y Gestión de Red

Esta guía explica cómo funciona el sistema de red en PiLab, incluyendo la gestión automática de conexiones y el sistema de failover.

## Descripción General

PiLab incluye un sistema inteligente de gestión de red que:
- Monitorea constantemente la conectividad a Internet
- Cambia automáticamente entre conexión WiFi y punto de acceso
- Registra todos los eventos de red

## Componentes Principales

### 1. Servicio de Monitoreo (network-check)

Ubicación: `/etc/systemd/system/network-check.service`

Este servicio:
- Verifica la conexión a Internet
- Gestiona el cambio entre modos de red
- Registra eventos de conectividad

## Configuración Inicial

### 1. Configuración WiFi

1. Editar configuración WiFi:
   ```bash
   sudo nano /etc/wpa_supplicant/wpa_supplicant.conf
   ```

2. Agregar red WiFi:
   ```
   network={
       ssid="nombre_de_tu_red"
       psk="contraseña_de_tu_red"
   }
   ```

### 2. Configuración de Red

1. Configurar interfaz de red:
   ```bash
   sudo nano /etc/network/interfaces
   ```

2. Configuración básica:
   ```
   auto wlan0
   iface wlan0 inet dhcp
   wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
   ```

## Monitoreo y Diagnóstico

### 1. Verificar Estado de Red

```bash
# Estado de interfaces
ip addr show

# Conexiones activas
netstat -tuln

# Estado de WiFi
iwconfig wlan0
```

### 2. Logs del Sistema

```bash
# Logs de red
sudo journalctl -u network-check

# Logs de sistema
sudo tail -f /var/log/syslog
```

## Solución de Problemas

### 1. Problemas de Conexión WiFi

1. Reiniciar servicios de red:
   ```bash
   sudo systemctl restart networking
   sudo systemctl restart wpa_supplicant
   ```

2. Verificar interferencias:
   ```bash
   sudo iwlist wlan0 scan | grep -E 'ESSID|Channel'
   ```

### 2. Problemas de DNS

1. Verificar resolución DNS:
   ```bash
   nslookup google.com
   ```

2. Comprobar configuración DNS:
   ```bash
   cat /etc/resolv.conf
   ```

## Configuración Avanzada

### 1. Prioridad de Interfaces

Para modificar el orden de preferencia de las interfaces:

1. Editar reglas de enrutamiento:
   ```bash
   sudo nano /etc/network/if-up.d/route-priorities
   ```

2. Ejemplo de configuración:
   ```bash
   #!/bin/sh
   if [ "$IFACE" = "eth0" ]; then
       ip route add default via $GATEWAY dev $IFACE metric 100
   elif [ "$IFACE" = "wlan0" ]; then
       ip route add default via $GATEWAY dev $IFACE metric 200
   fi
   ```

### 2. Configuración de Firewall

1. Reglas básicas de iptables:
   ```bash
   # Permitir tráfico establecido
   sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
   
   # Permitir SSH
   sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
   ```

## Mantenimiento

### 1. Backup de Configuración

```bash
# Respaldar configuraciones de red
sudo tar -czvf network-config-backup.tar.gz \
    /etc/network/interfaces \
    /etc/wpa_supplicant/wpa_supplicant.conf \
    /etc/hostapd/hostapd.conf
```

### 2. Actualización de Firmware

```bash
# Actualizar firmware de WiFi
sudo rpi-update
sudo reboot
```

## Integración con Otros Servicios

### 1. Docker Network

La red de Docker está configurada para trabajar con el sistema de red principal:

```bash
# Verificar redes Docker
docker network ls

# Inspeccionar red de PiLab
docker network inspect homelab_net
```

### 2. Proxy Inverso

Traefik está configurado para manejar el tráfico web:

```bash
# Verificar estado de Traefik
docker-compose logs traefik
```

## Notas de Seguridad

1. Mantén actualizados los componentes de red
2. Usa contraseñas fuertes para las redes WiFi
3. Monitorea regularmente los logs de red
4. Implementa reglas de firewall restrictivas
5. Realiza backups periódicos de la configuración

## Recursos Adicionales

- [Documentación de Raspberry Pi Networking](https://www.raspberrypi.org/documentation/computers/networking.html)
- [Guía de WPA Supplicant](https://wiki.archlinux.org/title/Wpa_supplicant)
- [Manual de Hostapd](https://wiki.gentoo.org/wiki/Hostapd)
- [Documentación de Iptables](https://netfilter.org/documentation/)