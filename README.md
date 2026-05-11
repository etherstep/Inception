> [!NOTE]
> *This project has been created as part of the 42 curriculum by **jpelline**.*

# Inception
A Docker-based infrastructure project deploying a secure WordPress stack — **NGINX (TLS)** → **WordPress (PHP-FPM)** → **MariaDB** — with **persistent storage** and **Docker secrets**.

> **TL;DR**
> - `make up` → build + start everything  
> - `make down` → stop stack (keep data)  
> - `make clean` → remove containers + images (keep data)  
> - `make fclean` → wipe data (fresh start)

---

## Description

### Goal
- <one or two sentences>

### Overview
- **NGINX** — TLS termination + reverse proxy (serves static assets, forwards PHP to PHP-FPM)
- **WordPress (PHP-FPM)** — PHP runtime running WordPress (no Apache)
- **MariaDB** — database backend for WordPress data
- **Networking** — services communicate over a dedicated Docker **bridge** network (`inception`)
- **Persistence** — WordPress files + MariaDB data are stored on the host (`/home/<user>/data/...`)
- **Entrypoint** — `Makefile` wraps `docker compose` commands (`make up`, `make down`, etc.)

### Docker & Sources
- <why Docker is used here>
- **Base images**: <Alpine/Debian + why>
- **Build-time vs runtime downloads**
  - Built from Dockerfiles: <...>
  - Downloaded at build/runtime: <...>

### Main Design Choices
- <design choice 1>
- <design choice 2>
- <design choice 3>

---

## Architecture & Trade-offs

### Virtual Machines vs Docker
- <bullet points>

### Secrets vs Environment Variables
- <bullet points>

### Docker Network vs Host Network
- <bullet points>

### Docker Volumes vs Bind Mounts
- <bullet points>

---

## Instructions

### Requirements
- <OS/VM requirement>
- <Docker version>
- <Docker Compose version>
- <other prerequisites>

### Setup
1. <step>
2. <step>
3. <step>

### Configuration

#### `.env`
- Required variables:
  - <VAR_1=...>
  - <VAR_2=...>

#### `secrets/`
- Required files:
  - <secret_file_1>
  - <secret_file_2>

#### Hosts / DNS
- <domain -> IP mapping instructions>

---

## Usage

### Build
```sh
make
```

### Run
```sh
make up
```

### Stop
```sh
make down
```

### Remove containers & images
```sh
make clean
```

### Wipe data
```sh
make fclean
```

---

## Resources

### References
- <link + short label>
- <link + short label>
- <link + short label>

### AI Usage
- Tools used: <tool/model name(s)>
- Used for:
  - <task 1>
  - <task 2>
  - <task 3>
- Not used for / verification approach:
  - <what you verified manually>
  - <how you tested>
