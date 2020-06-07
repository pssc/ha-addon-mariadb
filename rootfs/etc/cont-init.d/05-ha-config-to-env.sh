#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons: 
# ==============================================================================

# Paths
DDATAL=${DDATAL:-"/data/dump"}
MDATAL=${MDATAL:-"/data/databases"}
MCDDIR=${MCDDIR:-"/config/mariadb"}
MCFDIR=${MCFDIR:-"/config/mariadb/cnf.d"}
TCFDIR=${TCDDIR:-"/etc/mariadb.t.d"}
BDBDIR=${BDBDIR:-"/backup"}

#Database
DATABASES=${DATABASES:-""}
RIGHTS=${RIGHTS:-""}
LOGINS=${LOGINS:-""}

WAITS=${WAITS:-30}
DUMPS=${DUMPS:-3}

# FIXME move to cont-init scripts... export!


# hassio addon config
CONFIG=/data/options.json
if [ -r $CONFIG ];then
   #USERNAME=$(bashio::config 'username')
   DATABASES=$(jq --raw-output ".databases[]" $CONFIG)
   LOGINS=$(jq --raw-output '.logins | length |@sh' $CONFIG)
   LOGIND=$(jq --raw-output '.logins[]' $CONFIG)
   RIGHTS=$(jq --raw-output '.rights | length |@sh' $CONFIG)
   RIGHTD=$(jq --raw-output '.rights[]' $CONFIG)
   LOWMEM=${LOWMEM:-$(jq -r '.lowmem|values|@sh' $CONFIG)}
   TMPFS=${TMPFS:-$(jq -r '.tmpfs|values|@sh' $CONFIG)}
   BACKUP=${BACKUP:-$(jq -r '.backup|values|@sh' $CONFIG)}
   INTERNAL=${INTERNAL:-$(jq -r '.internal|values|@sh' $CONFIG)}
   RESTORE=${RESTORE:-$(jq -r '.restore|values|@sh' $CONFIG)}
   LIMIT=${LIMIT:-$(jq -r '.limit|values|@sh' $CONFIG)}

   REGISTER=${REGISTER:-$(jq -r '.register|values|@sh' $CONFIG)}
fi

# container defaults into other script
# mariadb Defauts for ha
LOWMEM=${LOWMEM:-"true"}
TMPFS=${TMPFS:-"true"}
BACKUP=${BACKUP:-"true"}
INTERNAL=${INTERNAL:-"false"}
RESTORE=${RESTORE:-"true"}
LIMIT=${LIMIT:-"false"}

# ha defaults
REGISTER=${REGISTER:-"true"}

#
echo -n ${DATABASES} >/run/s6/container_environment/DATABASES
echo -n ${LOGIND} >/run/s6/container_environment/LOGIND
echo -n ${LOGINS} >/run/s6/container_environment/LOGINS
echo -n ${RIGHTD} >/run/s6/container_environment/RIGHTD
echo -n ${RIGHTS} >/run/s6/container_environment/RIGHTS
#
echo -n ${LOWMEM} >/run/s6/container_environment/LOWMEM
echo -n ${TMPFS} >/run/s6/container_environment/TMPFS
echo -n ${BACKUP} >/run/s6/container_environment/BACKUP
echo -n ${INTERNAL} >/run/s6/container_environment/INTERNAL
echo -n ${RESTORE} >/run/s6/container_environment/RESTORE
echo -n ${LIMIT} >/run/s6/container_environment/LIMIT

echo -n ${REGISTER} >/run/s6/container_environment/REGISTER
