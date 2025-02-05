# Guía de Instalación de PiLab

Esta guía te ayudará a instalar PiLab paso a paso en tu Raspberry Pi. Está diseñada para ser fácil de seguir, incluso si no tienes mucha experiencia técnica.

## Requisitos Previos

### Hardware Necesario
- Raspberry Pi 4 o 5
- Tarjeta MicroSD (mínimo 16GB recomendado)
- Fuente de alimentación para Raspberry Pi
- Cable de red Ethernet (recomendado para la instalación inicial)

### Software Necesario
- Raspberry Pi OS Lite (64-bit) instalado en la tarjeta MicroSD
- Acceso SSH habilitado en tu Raspberry Pi

## Pasos de Instalación

### 1. Preparación Inicial

1. Conecta tu Raspberry Pi a la red mediante cable Ethernet
2. Accede a tu Raspberry Pi via SSH:
   ```bash
   ssh pi@raspberry.local
   ```
   (Reemplaza 'raspberry.local' con la dirección IP de tu Raspberry Pi si es necesario)

### 2. Descarga del Proyecto

1. Clona el repositorio de PiLab:
   ```bash
   git clone https://github.com/yourusername/pilab.git
   cd pilab
   ```

### 3. Ejecutar el Script de Instalación

1. Dale permisos de ejecución al script:
   ```bash
   chmod +x install.sh
   ```

2. Ejecuta el script de instalación como root:
   ```bash
   sudo ./install.sh
   ```

   Este script realizará automáticamente:
   - Actualización del sistema
   - Instalación de dependencias necesarias
   - Configuración de Docker
   - Creación de la estructura de directorios
   - Generación de contraseñas seguras
   - Configuración de servicios

### 4. Verificación de la Instalación

1. Verifica que Docker esté funcionando:
   ```bash
   sudo systemctl status docker
   ```

2. Comprueba que los contenedores estén en ejecución:
   ```bash
   docker ps
   ```

3. Verifica el servicio de red:
   ```bash
   sudo systemctl status network-check.service
   ```

## Solución de Problemas Comunes

### Docker no inicia
```bash
# Reinicia el servicio de Docker
sudo systemctl restart docker

# Verifica los logs
sudo journalctl -u docker
```

### Problemas de Red
```bash
# Verifica la configuración de red
ip addr show

# Reinicia el servicio de red
sudo systemctl restart network-check.service
```

## Próximos Pasos

Una vez completada la instalación, puedes continuar con:
1. Configuración del punto de acceso WiFi (ver `hotspot.md`)
2. Configuración de servicios Docker (ver `docker-services.md`)
3. Personalización de la configuración (ver `configuration.md`)

## Soporte

Si encuentras algún problema durante la instalación:
1. Revisa los logs en `/var/log/`
2. Consulta la documentación específica de cada componente en la carpeta `docs/`
3. Abre un issue en el repositorio del proyecto

## Notas de Seguridad

- Cambia la contraseña por defecto del usuario pi
- Revisa y actualiza las contraseñas generadas en `config/secrets/`
- Mantén tu sistema actualizado regularmente