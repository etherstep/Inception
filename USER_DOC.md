
# Very user-friendly documentation

◦ Understand what services are provided by the stack.
mariadb
nginx
wordpress

◦ Start and stop the project.
this project uses Makefile
commands:
make up
    create and start containers
make down
    stop and remove containers, networks
make stop
    stop services
make start
    start services
make clean
    same as make down
make fclean
    removes everything
make re
    executes fclean and make all

◦ Access the website and the administration panel.
https://jpelline.42.fr
https://jpelline.42.fr/wp-admin

◦ Locate and manage credentials.
◦ Check that the services are running correctly.

# User Documentation

## 1. What this project provides
### Services in the stack
- **NGINX (TLS reverse proxy)**
  - Purpose: <...>
  - Exposed ports: <...>
- **WordPress (php-fpm)**
  - Purpose: <...>
  - Exposed ports: <...> (internal only)
- **MariaDB**
  - Purpose: <...>
  - Exposed ports: <...> (internal only)

### How services connect (high level)
- <NGINX -> php-fpm>
- <WordPress -> MariaDB>
- <Docker network name>

## 2. Start / Stop
### Start
```sh
<make command to start>
```

### Stop
```sh
<make command to stop>
```

### Full reset (removes data)
```sh
<make clean/fclean command>
```

## 3. Access
### Website
- URL: `https://<domain>/`
- Notes:
  - <self-signed cert warning>
  - <expected landing page>

### WordPress administration panel
- URL: `https://<domain>/wp-admin`
- Login:
  - Username: <where to find it>
  - Password: <where to find it>

## 4. Credentials (where to find / how to manage)
### Non-secret configuration
- File: `.env`
- What it controls:
  - <DOMAIN_NAME, ports, etc.>

### Secrets
- Location: `<path to secrets dir>`
- Files:
  - `<db_name file>`
  - `<db_user file>`
  - `<db_password file>`
  - `<db_root_password file>`
  - `<wp_admin file>`
  - `<wp_admin_password file>`
  - `<wp_user file>`
  - `<wp_user_password file>`
- Rules:
  - <never commit secrets>
  - <how to rotate/update>

## 5. Check everything is running correctly
### Container status
```sh
<docker compose ps command>
```

### Healthchecks
- What “healthy” means for:
  - MariaDB: <...>
  - WordPress: <...>
  - NGINX: <...>

### Logs
```sh
<docker compose logs command>
```

### Basic functional checks
- HTTPS:
  - <curl command>
- WordPress:
  - <check wp-login/wp-admin>
- Database:
  - <optional check>
