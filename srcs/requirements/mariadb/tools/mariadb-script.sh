#!/bin/sh

# Fail fast (-e) and treat unset vars as errors (-u) 
# to avoid starting with partial config.
set -eu

# Required runtime settings come from .env 
# and are used to render my.cnf.
: "${MARIADB_PORT:?missing MARIADB_PORT}"
: "${MARIADB_BIND_ADDRESS:?missing MARIADB_BIND_ADDRESS}"

# Ensure runtime + data directories exist
# and are owned by mysql (needed when using a bind-mounted volume).
echo "==> Setting up MariaDB directory..."
mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql 

# Render MariaDB config at container start 
# so no ports/addresses are hardcoded in the image.
envsubst '${MARIADB_BIND_ADDRESS} ${MARIADB_PORT}' \
  < /etc/my.cnf.template > /etc/my.cnf
chmod 644 /etc/my.cnf

# Read Docker secrets from /run/secrets/* and strip newlines
# (avoids leaking creds into the image or git).
read_secret() {
  name="$1"
  path="/run/secrets/$name"
  [ -f "$path" ] && tr -d '\r\n' < "$path"
}

# Refuse to start if secrets weren't provided.
MYSQL_DATABASE="$(read_secret db_name)"
MYSQL_USER="$(read_secret db_user)"
MYSQL_PASSWORD="$(read_secret db_password)"
MYSQL_ROOT_PASSWORD="$(read_secret db_root_password)"

export MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD MYSQL_ROOT_PASSWORD

: "${MYSQL_DATABASE:?missing db_name secret}"
: "${MYSQL_USER:?missing db_user secret}"
: "${MYSQL_PASSWORD:?missing db_password secret}"
: "${MYSQL_ROOT_PASSWORD:?missing db_root_password secret}"


if [ ! -d "/var/lib/mysql/mysql" ]; then
    # First run only: initialize the system database into the persistent volume.
    echo "==> Initializing MariaDB system tables..."
    mariadb-install-db --basedir=/usr --user=mysql --datadir=/var/lib/mysql/ >/dev/null

    # Bootstrap without networking: set root password 
    # + create WP database/user with privileges.
    echo "==> Creating WordPress database and user..."
	mariadbd --user=mysql --bootstrap <<- EOF
	FLUSH PRIVILEGES;
	ALTER USER 'root'@'localhost' IDENTIFIED BY "${MYSQL_ROOT_PASSWORD}";
	CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
	CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY "${MYSQL_PASSWORD}";
	GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
	FLUSH PRIVILEGES;
	EOF

else
    echo "==> MariaDB is already installed. Database and users are configured."
fi

# Run mariadbd in the foreground as PID 1 
# so Docker can manage the container lifecycle properly.
echo "==> Starting MariaDB server..."
exec mariadbd --user=mysql
