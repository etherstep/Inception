FROM alpine:3.23.2
# 3.22.4

# Install php-fpm + extensions needed by WordPress, 
# plus mariadb-client for DB readiness checks and WP-CLI DB access.
RUN apk add --no-cache mariadb-client \
	php83 \
	php83-fpm \
	php83-phar \
	php83-curl \
	php83-mysqli \
	php83-iconv \
	php83-json \
	php83-posix \
	wget \
	curl \
	gettext \
	bash && \
	ln -s /usr/bin/php83 /usr/bin/php && \
	ln -s /usr/sbin/php-fpm83 /usr/sbin/php-fpm

# Install CA certs so HTTPS downloads (WP-CLI) verify correctly.
RUN apk add --no-cache curl ca-certificates && update-ca-certificates

# Download WP-CLI into the image so bootstrap can be done at runtime 
# without pulling full WordPress in the Dockerfile.
RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp \
    && /usr/local/bin/wp --info

# Create the WordPress document root 
# (actual content is stored in the bind-mounted volume at runtime).
RUN mkdir -p /var/www/html

# Copy php-fpm pool template; 
# entrypoint renders to www.conf using .env values 
COPY ./conf/www.conf.template /etc/php83/php-fpm.d/www.conf.template
RUN chmod 644 /etc/php83/php-fpm.d/www.conf.template

# Entrypoint bootstraps WordPress on first run
# (using Docker secrets) then execs php-fpm in foreground.
COPY ./tools/wordpress-script.sh /usr/local/bin/wordpress-script.sh
RUN chmod +x /usr/local/bin/wordpress-script.sh

# Ensure www-data user/group exists 
# and matches the user nginx/php-fpm run as.
RUN getent group www-data >/dev/null || addgroup -S www-data && \
    getent passwd www-data >/dev/null || adduser -S -D -H -s /sbin/nologin -G www-data www-data

# Pre-set ownership so the runtime volume 
# can be used without permission issues.
RUN chown -R www-data:www-data /var/www

# Start via entrypoint so configuration 
# and WordPress install happen at container start, 
# not at build time.
ENTRYPOINT ["/usr/local/bin/wordpress-script.sh"]
