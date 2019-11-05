ARG BUILD_FROM=hassioaddons/base:4.1.1
FROM ${BUILD_FROM}

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache mariadb mariadb-client xz

# Copy data
COPY rootfs/ /
COPY mariadb/mariadb-server-confdir.cnf /etc/my.cnf.d/
run mkdir /etc/mariadb.t.d/
COPY mariadb/mariadb.t.d/ /etc/mariadb.t.d/
RUN chmod a+x /run.sh

VOLUME /data
VOLUME /share
VOLUME /backup
VOLUME /config
VOLUME /ssl
#Also needed
#VOLUME /tmpfs

CMD [ "/run.sh" ]
