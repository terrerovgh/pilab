# Configuración del Punto de Acceso WiFi (Hotspot)

Esta guía explica cómo configurar y gestionar el punto de acceso WiFi automático de PiLab, que se activa cuando no hay conexión a Internet.

## Descripción General

El hotspot se activa automáticamente cuando:
- No hay conexión a Internet disponible
- El servicio network-check detecta una falla en la conectividad

## Configuración del Hotspot

### 1. Archivo de Configuración

El archivo principal de configuración se encuentra en `/etc/hostapd/hostapd.conf`. Los valores predeterminados son:

```bash
interface=wlan0
driver=nl80211
ssid=PiLab-Hotspot
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=pilab123456
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
```

### 2. Personalización

Para modificar la configuración del hotspot:

1. Edita el archivo de configuración:
   ```bash
   sudo nano /etc/hostapd/hostapd.conf
   ```

2. Modifica los siguientes valores según tus necesidades:
   - `ssid`: Nombre de la red WiFi
   - `wpa_passphrase`: Contraseña de la red
   - `channel`: Canal WiFi (1-11)

3. Guarda los cambios y reinicia el servicio:
   ```bash
   sudo systemctl restart hotspot.service
   ```

## Funcionamiento

### Activación Automática

El servicio `network-check` monitorea constantemente la conexión a Internet:
1. Si se pierde la conexión, el hotspot se activa automáticamente
2. Cuando se recupera la conexión, el hotspot se desactiva

### Verificación del Estado

Para verificar el estado del hotspot:
```bash
# Estado del servicio
sudo systemctl status hotspot.service

# Verificar interfaz WiFi
iw dev wlan0 info

# Ver clientes conectados
iw dev wlan0 station dump
```

## Solución de Problemas

### El Hotspot no se Activa

1. Verifica que el servicio esté habilitado:
   ```bash
   sudo systemctl enable hotspot.service
   ```

2. Comprueba los logs:
   ```bash
   sudo journalctl -u hotspot.service
   ```

3. Verifica la interfaz WiFi:
   ```bash
   sudo rfkill list all
   sudo rfkill unblock wifi
   ```

### Problemas de Conexión

1. Verifica la configuración de red:
   ```bash
   ip addr show wlan0
   ```

2. Comprueba que dnsmasq esté funcionando:
   ```bash
   sudo systemctl status dnsmasq
   ```

## Configuración Avanzada

### Personalización de la Red

Para modificar la configuración de red del hotspot:

1. Edita el archivo del servicio:
   ```bash
   sudo nano /etc/systemd/system/hotspot.service
   ```

2. Modifica la dirección IP y máscara de red:
   ```ini
   ExecStartPre=/sbin/ip addr add 192.168.50.1/24 dev wlan0
   ```

3. Recarga la configuración del sistema:
   ```bash
   sudo systemctl daemon-reload
   ```

## Notas de Seguridad

1. Cambia la contraseña predeterminada del hotspot
2. Considera usar una red oculta (modify `ignore_broadcast_ssid=1`)
3. Utiliza WPA2 para mayor seguridad
4. Actualiza regularmente el firmware de tu Raspberry Pi

## Integración con Otros Servicios

El hotspot está integrado con:
- Servicio de monitoreo de red
- Sistema de logs
- Servicios Docker

Consulta la documentación específica de cada servicio para más detalles sobre la integración.