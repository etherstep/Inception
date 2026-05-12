FROM alpine:3.22.4

RUN apk add --no-cache nginx openssl gettext

# Nginx config template + entrypoint (renders template with envsubst)
COPY ./conf/nginx.conf.template /etc/nginx/nginx.conf.template
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chmod 644 /etc/nginx/nginx.conf.template

# create www-data user/group only if they don't already exist
RUN getent group www-data >/dev/null || addgroup -S www-data && \
    getent passwd www-data >/dev/null || adduser -S -D -H -s /sbin/nologin -G www-data www-data

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
