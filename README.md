> [!NOTE]
> This project has been created as part of the 42 curriculum by **jpelline**.

# Inception
A Docker-based infrastructure project deploying a secure WordPress stack.

## Description

### Goal
- Design and run a small, secure, reproducible infrastructure using **Docker**.

### Overview
- **NGINX** — TLS termination + reverse proxy
- **WordPress** — PHP runtime
- **MariaDB** — database backend for WordPress data

## Architecture

### Virtual Machines vs Docker
- **Virtual machines** run a full guest OS (their own kernel) on top of a hypervisor, which adds more overhead in CPU/RAM/disk and usually boots slower.
- **Docker containers** are isolated processes that share the host kernel, so they start faster and use fewer resources while still providing separation (filesystem, network, users, etc.).
- Containers encourage a “one service per container” architecture (NGINX, PHP-FPM, MariaDB), which makes the stack easier to manage and reproduce.

### Secrets vs Environment Variables
- <fill in>

### Docker Network vs Host Network
- <fill in>

### Docker Volumes vs Bind Mounts
- <fill in>

## Instructions

### Requirements
- <OS/VM requirement>

### Setup
- <fill in>

### Configuration

#### `.env`
- Required variables:
  - `DOMAIN_NAME=`
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

#### Hosts / DNS
- <domain -> IP mapping instructions>

## Usage

### Build / Run
```sh
git clone https://github.com/etherstep/inception.git
cd inception
make
```

### Commands
```sh
make up      # build + run services
make down    # stop services
make clean   # remove containers and images
make fclean  # wipe all data
make status [service...]
make logs   [service...]
```

## Resources

### References
- https://docs.docker.com/guides/
- https://mariadb.com/docs/
- https://nginx.org/en/docs/
- https://www.youtube.com/watch?v=DQdB7wFEygo

### AI Usage
- AI was mostly used to assist in understanding concepts, writing complex scripts, and debugging.
