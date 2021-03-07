ARG BUILD_FROM=ghcr.io/hassio-addons/base:9.1.5
FROM ${BUILD_FROM}

RUN apk update && apk add --no-cache mariadb mariadb-client mariadb-server-utils xz pwgen && rm -f /var/cache/apk/*

COPY rootfs/ /
COPY mariadb/mariadb-server-confdir.cnf /etc/my.cnf.d/
RUN rm -f /etc/my.cnf.d/mariadb-server.cnf && mkdir /etc/mariadb.t.d/
COPY mariadb/mariadb.t.d/ /etc/mariadb.t.d/

VOLUME /data
VOLUME /share
VOLUME /backup
VOLUME /config
VOLUME /ssl
