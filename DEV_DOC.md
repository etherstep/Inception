# Developer Documentation

## 1. Prerequisites
- Docker
- Docker Compose
- Make

## 2. Configuration from scratch
### .env
- Create/edit:
  - `DOMAIN_NAME=`
  - `NGINX_HTTP_PORT=80`
  - `NGINX_HTTP_PORT_HOST=80`
  - `NGINX_HTTPS_PORT=443`
  - `NGINX_HTTPS_PORT_HOST=443`
  - `PHP_FPM_PORT=9000`
  - `MARIADB_PORT=3306`
  - `MARIADB_BIND_ADDRESS=0.0.0.0`
  - `WORDPRESS_TITLE=...`
  - `LOGIN=${USER}`

### Secrets
- Create files in: `./secrets`
- Required secret files:
  - `db_name.txt`
  - `db_password.txt`
  - `db_root_password.txt`
  - `db_user.txt`
  - `wp_admin.txt`
  - `wp_admin_email.txt`
  - `wp_admin_password.txt`
  - `wp_user.txt`
  - `wp_user_email.txt`
  - `wp_user_password.txt`

### Host directories for persistent data (bind mounts)
- Create manually or let makefile handle it:
```sh
mkdir -p /home/$USER/data/mariadb
mkdir -p /home/$USER/data/wordpress
```

### Domain / hosts entry
- Add mapping:
  - `127.0.0.1 ${DOMAIN_NAME}`
- Verify:
```sh
ping jpelline.42.fr
curl -k https://${DOMAIN_NAME}
```

## 4. Build and launch
```sh
make up      # build + run services
make down    # stop services
make clean   # remove containers and images
make fclean  # wipe all data
```

## 5. Useful operational commands
```sh
# Enter the MariaDB container shell
docker exec -it srcs-mariadb-1 sh

# Connect to MariaDB using the application database user
mysql -u <db_user> -p

# List all databases on the server
SHOW DATABASES;

# Switch to the WordPress database
USE wordpress_db;

# List all tables inside the WordPress database
SHOW TABLES;

# Show privileges assigned to the database user
SHOW GRANTS FOR '<db_user>'@'%';

# Run a one-liner to list databases without entering the shell
docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# Check if MariaDB is listening on port 3306
ss -tulnp | grep 3306

# Inspect networks / volumes
docker network ls
docker volume ls
docker volume inspect <volume>
```

## 6. Data persistence model
### Where data lives (host)
- MariaDB data: `/home/$USER/data/mariadb`
- WordPress files: `/home/$USER/data/wordpress`

### What is persisted vs ephemeral
- Persisted:
  - MariaDB databases/users
  - WordPress uploads/plugins/themes
- Ephemeral:
  - Container filesystem outside mounted volumes
  - Temporary/generated runtime files

### Reset strategy
- Soft reset:
```sh
make down
make up
```
- Hard reset:
```sh
make fclean
sudo rm -rf /home/$USER/data/*
```

## 7. Debugging checklist
- NGINX TLS:
```sh
curl -vk https://${DOMAIN_NAME}
openssl s_client -connect ${DOMAIN_NAME}:443
```
- WordPress/php-fpm:
```sh
docker compose logs wordpress
ss -tulnp | grep 9000
```
- MariaDB:
```sh
docker compose logs mariadb
docker compose exec mariadb mariadb -u root -p
```
- Permissions:
```sh
ls -lah /home/$USER/data
ls -lah /var/www/html
```
