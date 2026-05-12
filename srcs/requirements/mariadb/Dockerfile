FROM alpine:3.22.4

RUN apk add --no-cache mariadb mariadb-client gettext

COPY ./conf/mariadb.cnf.template /etc/my.cnf.template
RUN chmod 644 /etc/my.cnf.template

COPY ./tools/mariadb-script.sh /usr/local/bin/mariadb-script.sh 
RUN chmod +x /usr/local/bin/mariadb-script.sh

ENTRYPOINT ["sh", "/usr/local/bin/mariadb-script.sh"]
