# Very user-friendly documentation

## 1. What this project provides

### Services in the stack

- **NGINX (TLS reverse proxy)**
  - Web server serving WordPress via HTTPS
  - Exposed ports: 443, 80
    
- **WordPress (php-fpm)**
  - Purpose: WordPress application backend (PHP execution layer)
  - Exposed ports: 9000 (internal only)
    
- **MariaDB**
  - Purpose: database for wordpress data
  - Exposed ports: 3306 (internal only)

### How services connect
- NGINX → PHP-FPM (WordPress processing)
- WordPress → MariaDB (database queries)
- Docker network: internal bridge network (`inception` or project network name)

## 2. Start / Stop
```sh
make up      # build + run services
make down    # stop services
make clean   # remove containers and images
make fclean  # wipe all data
```

## 3. Access
### Website
- URL: `https://jpelline.42.fr`
- Notes:
  - Self-signed certificate warning is expected (ignore in browser)

### WordPress administration panel
- URL: `https://jpelline.42.fr/wp-admin`
- Login:
  - Username: from /secrets/wp_admin.txt
  - Password: from /secrets/wp_admin_password.txt

## 4. Credentials (where to find / how to manage)
### Non-secret configuration
- File: `.env`
- What it controls:
  - Domain name, ports, and general service configuration

 ### Configuration

#### `.env`
- Required variables:
  - `DOMAIN_NAME=jpelline.42.fr`
  - `NGINX_HTTP_PORT=80`
  - `NGINX_HTTPS_PORT=443`
  - `PHP_FPM_PORT=9000`
  - `MARIADB_PORT=3306`
  - `MARIADB_BIND_ADDRESS=0.0.0.0`
  - `WORDPRESS_TITLE=`
  - `LOGIN=${USER}`

#### `secrets/`
- Required files:
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

## 5. Check everything is running correctly
### Container status
```sh
docker compose ps
make status [service...]
```

### Healthchecks
  - MariaDB: database is ready to accept connections
  - WordPress (PHP-FPM): responds to PHP execution requests via NGINX
  - NGINX: responds on HTTPS (443) and serves WordPress page

### Logs
```sh
docker compose logs
make logs [service...]
```

### Basic functional checks
- HTTPS:
  - ```sh curl -k https://jpelline.42.fr```
- WordPress:
  - Visit /wp-admin and verify login works
- Database:
  - `docker exec` into MariaDB container and check tables exist (`mysql -u ...`)
 
```sh
# Enter the MariaDB container shell
docker exec -it mariadb bash

# Connect to MariaDB using the application database user
mysql -u <db_user> -p

# List all databases on the server
SHOW DATABASES;

# Switch to the WordPress database
USE wordpress;

# List all tables inside the WordPress database
SHOW TABLES;

# Show privileges assigned to the database user
SHOW GRANTS FOR '<db_user>'@'%';

# Run a one-liner to list databases without entering the shell
docker exec mariadb mysql -u root -p -e "SHOW DATABASES;"

# Check if MariaDB is listening on port 3306
ss -tulnp | grep 3306
```
