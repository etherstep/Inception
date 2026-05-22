#!/bin/sh

# Fail fast (-e) and treat unset vars as errors (-u).
set -eu

# Required runtime settings come from .env and are used for cert generation + config rendering.
: "${DOMAIN_NAME:?missing DOMAIN_NAME}"
: "${NGINX_HTTP_PORT:?missing NGINX_HTTP_PORT}"
: "${NGINX_HTTP_PORT_HOST:?missing NGINX_HTTP_PORT_HOST}"
: "${NGINX_HTTPS_PORT:?missing NGINX_HTTPS_PORT}"
: "${NGINX_HTTPS_PORT_HOST:?missing NGINX_HTTPS_PORT_HOST}"
: "${PHP_FPM_PORT:?missing PHP_FPM_PORT}"

# Ensure SSL directory exists (useful when the container starts from a clean filesystem).
mkdir -p /etc/nginx/ssl

# Generate a self-signed cert at runtime so the CN matches DOMAIN_NAME from .env 
# (no hardcoded domain in the image).
if [ ! -f /etc/nginx/ssl/certificate.crt ] || [ ! -f /etc/nginx/ssl/private.key ]; then
  openssl req -x509 -nodes -days 365 \
    -out /etc/nginx/ssl/certificate.crt \
    -keyout /etc/nginx/ssl/private.key \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=42/OU=Hive/CN=${DOMAIN_NAME}"
fi

# Render nginx.conf from a template while restricting substitutions 
# to avoid touching nginx runtime vars like $host/$uri.
envsubst '${DOMAIN_NAME} ${NGINX_HTTP_PORT} ${NGINX_HTTP_PORT_HOST} ${NGINX_HTTPS_PORT} ${NGINX_HTTPS_PORT_HOST} ${PHP_FPM_PORT}' \
  < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Start the main container process (nginx) as PID 1.
exec "$@"
