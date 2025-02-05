# Configuración de Servicios Docker

Esta guía explica cómo configurar y gestionar los servicios Docker que componen PiLab. Cada servicio está diseñado para funcionar de manera integrada, proporcionando diferentes funcionalidades al sistema.

## Servicios Disponibles

### 1. Traefik (Proxy Inverso)
- Puerto: 80, 443
- Función: Gestiona el tráfico web y proporciona SSL

### 2. Nginx (Servidor Web)
- Puerto: Interno
- Función: Sirve la interfaz web de administración

### 3. Bind (Servidor DNS)
- Puerto: 53
- Función: Resolución de nombres local

### 4. MariaDB (Base de Datos)
- Puerto: Interno
- Función: Almacenamiento de datos

### 5. Squid (Proxy)
- Puerto: Interno
- Función: Caché web y control de acceso

## Configuración Inicial

### 1. Variables de Entorno

1. Copia el archivo de ejemplo:
   ```bash
   cp config/.env.example config/.env
   ```

2. Edita las variables según tu configuración:
   ```bash
   nano config/.env
   ```

### 2. Contraseñas y Secretos

Los secretos se almacenan en `config/secrets/`:
- `db_root_password.txt`: Contraseña de root de MariaDB
- `twingate_token.txt`: Token de acceso para Twingate

## Gestión de Servicios

### Iniciar Servicios
```bash
cd /opt/pilab/config
docker-compose up -d
```

### Detener Servicios
```bash
docker-compose down
```

### Ver Logs
```bash
# Todos los servicios
docker-compose logs

# Servicio específico
docker-compose logs [servicio]
```

## Configuración de Servicios

### Traefik

1. Configuración básica en `config/traefik/traefik.toml`:
   ```toml
   [entryPoints]
     [entryPoints.web]
       address = ":80"
     [entryPoints.websecure]
       address = ":443"
   ```

### Base de Datos

1. Acceder a MariaDB:
   ```bash
   docker-compose exec database mysql -u root -p
   ```

2. Crear nuevo usuario:
   ```sql
   CREATE USER 'usuario'@'%' IDENTIFIED BY 'contraseña';
   GRANT ALL PRIVILEGES ON *.* TO 'usuario'@'%';
   FLUSH PRIVILEGES;
   ```

## Monitoreo y Mantenimiento

### Verificar Estado
```bash
# Estado de contenedores
docker-compose ps

# Uso de recursos
docker stats
```

### Actualizar Servicios
```bash
# Descargar nuevas imágenes
docker-compose pull

# Reiniciar con nuevas imágenes
docker-compose up -d
```

## Solución de Problemas

### Contenedor no Inicia
1. Verificar logs:
   ```bash
   docker-compose logs [servicio]
   ```

2. Verificar configuración:
   ```bash
   docker-compose config
   ```

### Problemas de Red
1. Verificar red Docker:
   ```bash
   docker network ls
   docker network inspect homelab_net
   ```

2. Reiniciar red:
   ```bash
   docker-compose down
   docker network prune
   docker-compose up -d
   ```

## Backup y Restauración

### Backup de Datos
```bash
# Base de datos
docker-compose exec database mysqldump -u root -p --all-databases > backup.sql

# Volúmenes
tar -czvf config-backup.tar.gz config/
```

### Restaurar Backup
```bash
# Base de datos
cat backup.sql | docker-compose exec -T database mysql -u root -p

# Volúmenes
tar -xzvf config-backup.tar.gz
```

## Notas de Seguridad

1. Mantén las imágenes actualizadas
2. Usa contraseñas fuertes
3. Limita el acceso a los puertos expuestos
4. Revisa los logs regularmente
5. Realiza backups periódicos

## Recursos Adicionales

- [Documentación de Docker](https://docs.docker.com/)
- [Documentación de Docker Compose](https://docs.docker.com/compose/)
- [Guía de Traefik](https://doc.traefik.io/traefik/)
- [Documentación de MariaDB](https://mariadb.org/documentation/)