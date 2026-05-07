# Developer Documentation

## 1. Prerequisites
- OS/VM: <...>
- Docker: <version>
- Docker Compose: <version>
- Make: <version>
- OpenSSL: <version> (if needed on host)
- Notes:
  - <any 42 VM constraints>

## 2. Repository structure
- `srcs/`
  - `docker-compose.yml` — <...>
  - `.env` — <...>
  - `Makefile` — <...>
  - `requirements/`
    - `nginx/` — <Dockerfile/conf/tools>
    - `wordpress/` — <Dockerfile/conf/tools>
    - `mariadb/` — <Dockerfile/conf/tools>
- `secrets/` — <what it contains + permissions>

## 3. Configuration from scratch
### .env
- Create/edit:
  - `DOMAIN_NAME=...`
  - `NGINX_HTTPS_PORT=...`
  - `PHP_FPM_PORT=...`
  - `MARIADB_PORT=...`
  - `MARIADB_BIND_ADDRESS=...`
  - `WORDPRESS_TITLE=...`
- Notes:
  - <rules about not storing passwords here>

### Secrets
- Create files in: `<path>`
- Required secret files:
  - `<list>`
- Permissions:
  - <chmod recommendations>

### Host directories for persistent data (bind mounts)
- Create:
```sh
<mkdir -p /home/<login>/data/...>
```
- Ownership:
```sh
<chown command>
```

### Domain / hosts entry
- Add mapping:
  - `<VM_IP> <login>.42.fr`
- Verify:
```sh
<ping/curl command>
```

## 4. Build and launch (Makefile + Compose)
### Build images
```sh
<make build command>
```

### Launch
```sh
<make up command>
```

### Stop
```sh
<make down command>
```

### Clean / full reset
```sh
<make clean/fclean command>
```

## 5. Useful operational commands
### Inspect status
```sh
docker compose -f srcs/docker-compose.yml ps
```

### Follow logs
```sh
docker compose -f srcs/docker-compose.yml logs -f --tail=100
```

### Exec into containers
```sh
docker compose -f srcs/docker-compose.yml exec <service> sh
```

### Inspect networks / volumes
```sh
docker network ls
docker volume ls
docker volume inspect <volume>
```

## 6. Data persistence model
### Where data lives (host)
- MariaDB data: `/home/<login>/data/mariadb`
- WordPress files: `/home/<login>/data/wordpress`

### What is persisted vs ephemeral
- Persisted:
  - <db tables/users>
  - <wp-content/uploads/plugins/themes>
- Ephemeral:
  - <container filesystem outside volumes>
  - <generated configs if not persisted>

### Reset strategy
- Soft reset:
  - <restart containers>
- Hard reset:
  - <down -v + delete /home/<login>/data/*>

## 7. Debugging checklist
- NGINX TLS:
  - <openssl s_client / curl -vk>
- WordPress/php-fpm:
  - <php-fpm logs / socket/port>
- MariaDB:
  - <healthcheck / logs / connection test>
- Permissions:
  - <ownership of /home/<login>/data and /var/www/html>
