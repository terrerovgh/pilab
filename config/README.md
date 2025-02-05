# Docker Configuration and Network Setup

## Network Architecture

### Docker Network Configuration
- Network Name: homelab_net
- Network Type: bridge
- Subnet: 172.20.0.0/24
- Gateway: 172.20.0.1

### Container IP Assignments
| Service   | IP Address    | Ports                |
|-----------|--------------|----------------------|
| Traefik   | 172.20.0.2   | 80/TCP, 443/TCP     |
| Web Server| 172.20.0.3   | 8080/TCP            |
| DNS Server| 172.20.0.4   | 53/TCP, 53/UDP      |
| Database  | 172.20.0.5   | 3306/TCP            |
| Squid     | 172.20.0.6   | 3128/TCP            |
| Twingate  | 172.20.0.7   | 443/TCP             |

## Container Configurations

### 1. Traefik (Reverse Proxy)
```yaml
traefik:
  image: traefik:v2.5
  container_name: traefik
  restart: unless-stopped
  networks:
    homelab_net:
      ipv4_address: 172.20.0.2
  ports:
    - "80:80"
    - "443:443"
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
    - ./traefik/traefik.toml:/etc/traefik/traefik.toml:ro
    - ./traefik/acme.json:/acme.json
```

### 2. Web Server (Nginx)
```yaml
webserver:
  image: nginx:alpine
  container_name: webserver
  restart: unless-stopped
  networks:
    homelab_net:
      ipv4_address: 172.20.0.3
  volumes:
    - ./nginx/conf.d:/etc/nginx/conf.d:ro
    - ./nginx/html:/usr/share/nginx/html:ro
  labels:
    - "traefik.enable=true"
    - "traefik.http.routers.webserver.rule=Host(`homelab.local`)"
```

### 3. DNS Server (Bind)
```yaml
dns-server:
  image: sameersbn/bind:latest
  container_name: dns-server
  restart: unless-stopped
  networks:
    homelab_net:
      ipv4_address: 172.20.0.4
  ports:
    - "53:53/tcp"
    - "53:53/udp"
  volumes:
    - ./bind:/data
```

### 4. Database (MariaDB)
```yaml
database:
  image: mariadb:10.5
  container_name: database
  restart: unless-stopped
  networks:
    homelab_net:
      ipv4_address: 172.20.0.5
  environment:
    - MYSQL_ROOT_PASSWORD_FILE=/run/secrets/db_root_password
    - MYSQL_DATABASE=homelab
  volumes:
    - ./mariadb/data:/var/lib/mysql
    - ./mariadb/conf.d:/etc/mysql/conf.d:ro
  secrets:
    - db_root_password
```

### 5. Squid Proxy
```yaml
squid:
  image: ubuntu/squid:latest
  container_name: squid
  restart: unless-stopped
  networks:
    homelab_net:
      ipv4_address: 172.20.0.6
  volumes:
    - ./squid/squid.conf:/etc/squid/squid.conf:ro
```

### 6. Twingate
```yaml
twingate:
  image: twingate/connector:1
  container_name: twingate
  restart: unless-stopped
  networks:
    homelab_net:
      ipv4_address: 172.20.0.7
  environment:
    - TENANT_URL=your-network.twingate.com
    - ACCESS_TOKEN=/run/secrets/twingate_token
  secrets:
    - twingate_token
```

## Required Configuration Files

### Directory Structure
```
config/
├── bind/
│   └── named.conf
├── mariadb/
│   ├── conf.d/
│   │   └── custom.cnf
│   └── data/
├── nginx/
│   ├── conf.d/
│   │   └── default.conf
│   └── html/
│       └── index.html
├── squid/
│   └── squid.conf
├── traefik/
│   ├── acme.json
│   └── traefik.toml
└── docker-compose.yml
```

## Security Considerations
1. All sensitive data stored in Docker secrets
2. Minimal container privileges
3. Read-only volume mounts where possible
4. Internal network isolation
5. Regular security updates

## Backup Recommendations
1. Database dumps (daily)
2. Configuration files (on change)
3. SSL certificates
4. DNS zone files

## Monitoring
- Container health checks
- Resource usage monitoring
- Network traffic monitoring
- Log aggregation