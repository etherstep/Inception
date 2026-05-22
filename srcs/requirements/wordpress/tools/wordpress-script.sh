#!/bin/sh

# Fail fast (-e) and treat unset vars as errors (-u).
set -eu

# Container entrypoint for one-time WP bootstrap
# + then run php-fpm in the foreground.
echo "==> Setting up WordPress..."

# Adjust PHP settings at runtime 
# (keeps image generic and avoids baking config into build layers).
echo "memory_limit = 512M" >> /etc/php83/php.ini

# Work from the shared WordPress volume.
WP_PATH=/var/www/html
cd "$WP_PATH"

# Ensure WP-CLI is executable 
chmod +x /usr/local/bin/wp

# Required runtime settings come from .env
# and are used to render php-fpm config.
: "${PHP_FPM_PORT:?missing PHP_FPM_PORT}"

# Render php-fpm pool config at container start 
# so the listen port is not hardcoded in the image.
envsubst '${PHP_FPM_PORT}' \
  < /etc/php83/php-fpm.d/www.conf.template > /etc/php83/php-fpm.d/www.conf

# Read a Docker secret from /run/secrets/ and strip newlines.
read_secret() {
   name="$1"
   path="/run/secrets/$name"
   if [ -f "$path" ]; then
     tr -d '\r\n' < "$path"
   else
     return 1
   fi
}

# Prefer Docker secrets, with optional env var fallback 
export MYSQL_DATABASE="$(read_secret db_name || printf '%s' "${MYSQL_DATABASE:-}")"
export MYSQL_USER="$(read_secret db_user || printf '%s' "${MYSQL_USER:-}")"
export MYSQL_PASSWORD="$(read_secret db_password || printf '%s' "${MYSQL_PASSWORD:-}")"
export MYSQL_ROOT_PASSWORD="$(read_secret db_root_password || printf '%s' "${MYSQL_ROOT_PASSWORD:-}")"
export WP_USER="$(read_secret wp_user || printf '%s' "${WP_USER:-}")"
export WP_USER_PASSWORD="$(read_secret wp_user_password || printf '%s' "${WP_USER_PASSWORD:-}")"
export WP_USER_EMAIL="$(read_secret wp_user_email || printf '%s' "${WP_USER_EMAIL:-}")"
export WP_ADMIN="$(read_secret wp_admin || printf '%s' "${WP_ADMIN:-}")"
export WP_ADMIN_PASSWORD="$(read_secret wp_admin_password || printf '%s' "${WP_ADMIN_PASSWORD:-}")"
export WP_ADMIN_EMAIL="$(read_secret wp_admin_email || printf '%s' "${WP_ADMIN_EMAIL:-}")"

# Refuse to start if required secrets/vars are missing.
: "${MYSQL_DATABASE:?missing db_name}"
: "${MYSQL_USER:?missing db_user}"
: "${MYSQL_PASSWORD:?missing db_password}"
: "${WP_USER:?missing wp_user}"
: "${WP_USER_PASSWORD:?missing wp_user_password}"
: "${WP_USER_EMAIL:?missing wp_user_email}"
: "${WP_ADMIN:?missing wp_admin}"
: "${WP_ADMIN_PASSWORD:?missing wp_admin_password}"
: "${WP_ADMIN_EMAIL:?missing wp_admin_email}"
: "${DOMAIN_NAME:?missing DOMAIN_NAME in .env}"
: "${WORDPRESS_TITLE:?missing WORDPRESS_TITLE in .env}"

# Block until MariaDB is reachable before running WP-CLI commands.
echo "==> Waiting for MariaDB..."
mariadb-admin ping --protocol=tcp --host=mariadb -u $MYSQL_USER --password=$MYSQL_PASSWORD --wait=300

# Ensure wp-content exists on the volume 
# and WordPress files are writable by the web user.
mkdir -p "$WP_PATH/wp-content"
chown -R www-data:www-data "$WP_PATH"

# Run WP-CLI as www-data so generated files 
# are not owned by root on the shared volume.
wp_as_www_data() {
  su -s /bin/sh -c "$*" www-data
}

# First-run bootstrap: download core, 
# write wp-config, and install WordPress.
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "==> Downloading WordPress core..."
    wp_as_www_data "wp core download --path='$WP_PATH'"

    echo "==> Creating wp-config.php..."
    wp_as_www_data "wp config create --path='$WP_PATH' \
        --dbname='$MYSQL_DATABASE' \
        --dbuser='$MYSQL_USER' \
        --dbpass='$MYSQL_PASSWORD' \
        --dbhost='mariadb' \
	--skip-check"

    echo "==> Installing WordPress..."
    wp_as_www_data "wp core install --path='$WP_PATH' \
        --url='https://${DOMAIN_NAME}:${NGINX_HTTPS_PORT_HOST}' \
        --title='${WORDPRESS_TITLE}' \
        --admin_user='${WP_ADMIN}' \
        --admin_password='${WP_ADMIN_PASSWORD}' \
        --admin_email='${WP_ADMIN_EMAIL}' \
        --skip-email"
else
    echo "==> wp-config.php already exists; assuming WordPress is configured."
fi

# Always force correct siteurl/home for this environment
wp_as_www_data "wp option update siteurl 'https://${DOMAIN_NAME}:${NGINX_HTTPS_PORT_HOST}' --path='$WP_PATH'"
wp_as_www_data "wp option update home 'https://${DOMAIN_NAME}:${NGINX_HTTPS_PORT_HOST}' --path='$WP_PATH'"


# Insert reverse proxy and port handling code if not present
FIXLINE="HTTP_X_FORWARDED_PORT"
if ! grep -q "$FIXLINE" "$WP_PATH/wp-config.php"; then
  # Insert above the "That's all, stop editing!" comment
  sed -i "/^\/\* That's all, stop editing! Happy publishing. \*\//i\\
if (\n\
    isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) &&\n\
    \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https'\n\
) {\n\
    \$_SERVER['HTTPS'] = 'on';\n\
}\n\
if (\n\
    isset(\$_SERVER['HTTP_X_FORWARDED_PORT']) &&\n\
    \$_SERVER['HTTP_X_FORWARDED_PORT'] !== '443'\n\
) {\n\
    \$_SERVER['SERVER_PORT'] = \$_SERVER['HTTP_X_FORWARDED_PORT'];\n\
}\n" "$WP_PATH/wp-config.php"
  echo "Patched wp-config.php for proxy port handling!"
fi

# Idempotently insert the fixup code if not present
if ! grep -q 'HTTP_X_FORWARDED_PORT' "$WP_PATH/wp-config.php"; then
    sed -i "/^\/\* That's all, stop editing! Happy publishing. \*\//i $WP_PROXY_CODE" "$WP_PATH/wp-config.php"
fi

# Ensure the required non-admin user exists
echo "==> Ensuring extra user exists..."
if wp_as_www_data "wp user get '${WP_USER}' --path='${WP_PATH}' >/dev/null 2>&1"; then
    echo "==> Extra user '${WP_USER}' already exists."
elif wp_as_www_data "wp user list --field=user_email --path='${WP_PATH}' | grep -Fxq '${WP_USER_EMAIL}'"; then
    echo "==> A user with email '${WP_USER_EMAIL}' already exists; skipping create."
else
    wp_as_www_data "wp user create '${WP_USER}' '${WP_USER_EMAIL}' \
        --user_pass='${WP_USER_PASSWORD}' \
        --role=subscriber \
        --path='${WP_PATH}'"
fi

# Normalize permissions on the shared volume 
# so nginx/php-fpm can read files.
chown -R www-data:www-data "$WP_PATH"
chmod -R 755 "$WP_PATH"

# Run php-fpm in the foreground as PID 1 \
# so Docker can manage the container lifecycle properly.
echo "==> Running PHP-FPM in the foreground..."
exec php-fpm83 -F
