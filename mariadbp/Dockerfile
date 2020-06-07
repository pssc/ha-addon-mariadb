ARG BUILD_FROM=hassioaddons/base:7.0.2
FROM ${BUILD_FROM}

# Add env
ENV LANG C.UTF-8

# Setup base
RUN apk add --no-cache mariadb mariadb-client mariadb-server-utils xz pwgen

# Copy data
COPY rootfs/ /
COPY mariadb/mariadb-server-confdir.cnf /etc/my.cnf.d/
RUN rm /etc/my.cnf.d/mariadb-server.cnf
run mkdir /etc/mariadb.t.d/
COPY mariadb/mariadb.t.d/ /etc/mariadb.t.d/
#RUN chmod a+x /run.sh

VOLUME /data
VOLUME /share
VOLUME /backup
VOLUME /config
VOLUME /ssl
VOLUME /tmpfs

#CMD [ "/run.sh" ]
