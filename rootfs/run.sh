#!/bin/bash
set -ex

# Paths
MDATAL=${MDATAL:-"/data/databases"}
MCDDIR=${MCDDIR:-"/config/mariadb"}
MCFDIR=${MCFDIR:-"/config/mariadb/cnf.d"}
TCFDIR=${TCDDIR:-"/etc/mariadb.t.d"}
BDBDIR=${BDBDIR:-"/backup"}

#Database
DATABASES=${DATABASES:-""}
RIGHTS=${RIGHTS:-""}
LOGINS=${LOGINS:-""}

# Defaut swithces
LOWMEM=${LOWMEM:-"true"}
LIMIT=${LIMIT:-"false"}
TMPFS=${TMPFS:-"false"}
DUMP=${DUMP:-"true"}
RESTORE=${RESTORE:-"false"}

WAITS=${WAITS:-30}

# hassio addon config
CONFIG=/data/options.json
if [ -r $CONFIG ];then
   DATABASES=$(jq --raw-output ".databases[]" $CONFIG)
   LOGINS=$(jq --raw-output '.logins | length ' $CONFIG)
   RIGHTS=$(jq --raw-output '.rights | length ' $CONFIG)
   LOWMEM=${LOWMEM:-$(jq --raw-output '.lowmem' $CONFIG)}
   TMPFS=${TMPFS:-$(jq --raw-output '.tmpfs' $CONFIG)}
   DUMP=${DUMP:-$(jq --raw-output '.dump' $CONFIG)}
   RESTORE=${RESTORE:-$(jq --raw-output '.restore' $CONFIG)}
   LIMIT=${LIMIT:-$(jq --raw-output '.limit' $CONFIG)}
fi

if [ "$TMPFS" = "true" ];then
   MDATAL="/tmpfs/databases"
fi

mkdir -p "$MCDDIR"
cp -vr "$TCFDIR/." "$MCFDIR/"
echo "$MDATAL" >>"$MCFDIR/03-location.cnf"

if [ -r "$MCDIR/pre.sh" ];then
   . "$MCDIR/pre.sh";
fi

# Init mariadb
if [ ! -d "$MDATAL" ]; then
     echo "[INFO] Create a new mariadb initial system in $MDATAL"
    mysql_install_db --user=root --datadir="$MDATAL" > /dev/null
    if [ "$RESTORE" = "true" ];then
        restore_mariadb
    fi
else
    echo "[INFO] Using existing mariadb system in $MDATAL"
    EXISTING="true"
fi

# Start mariadb
echo "[INFO] Start MariaDB"
mysqld_safe --datadir="$MDATAL" --user=root --skip-log-bin < /dev/null &
MARIADB_PID=$!

WC=0
# Wait until DB is running
while ! mysql -e "" 2> /dev/null; do
    sleep 1
    WC=$(($WC+1))
    if [ "$WC" -gt "$WAITS" ];then exit 2;fi
done
echo "[INFO] Waited $WC counts for mariadb"

if [ "$EXISTING" = "true" ];then
    echo "[INFO] Check data integrity and fix corruptions"
    mysqlcheck --no-defaults --check-upgrade --auto-repair --databases mysql --skip-write-binlog > /dev/null || true
    mysqlcheck --no-defaults --all-databases --fix-db-names --fix-table-names --skip-write-binlog > /dev/null || true
    mysqlcheck --no-defaults --check-upgrade --all-databases --auto-repair --skip-write-binlog > /dev/null || true
fi

# Init databases
echo "[INFO] Init custom database(s)"
for line in $DATABASES; do
    echo "[INFO] Create database $line"
    mysql -e "CREATE DATABASE $line;" 2> /dev/null || true
done

# Init logins
echo "[INFO] Init/Update users"
for (( i=0; i < "$LOGINS"; i++ )); do
    USERNAME=$(jq --raw-output ".logins[$i].username" $CONFIG)
    PASSWORD=$(jq --raw-output ".logins[$i].password" $CONFIG)
    HOST=$(jq --raw-output ".logins[$i].host" $CONFIG)

    if mysql -e "SET PASSWORD FOR '$USERNAME'@'$HOST' = PASSWORD('$PASSWORD');" 2> /dev/null; then
        echo "[INFO] Update user $USERNAME@$HOST"
    else
        echo "[INFO] Create user $USERNAME@$HOST"
        mysql -e "CREATE USER '$USERNAME'@'$HOST' IDENTIFIED BY '$PASSWORD';" 2> /dev/null || true
    fi
done

# Init rights
echo "[INFO] Init/Update rights"
for (( i=0; i < "$RIGHTS"; i++ )); do
    USERNAME=$(jq --raw-output ".rights[$i].username" $CONFIG)
    HOST=$(jq --raw-output ".rights[$i].host" $CONFIG)
    DATABASE=$(jq --raw-output ".rights[$i].database" $CONFIG)
    GRANT=$(jq --raw-output ".rights[$i].grant" $CONFIG)

    echo "[INFO] Alter rights for $USERNAME@$HOST - $DATABASE"
    mysql -e "GRANT $GRANT $DATABASE.* TO '$USERNAME'@'$HOST';" 2> /dev/null || true
done

function dump_mariadb() {
    FILED="$BDBDIR/mariadb-dump.$(date -Iseconds).xz"
    echo "[INFO] Dumping mariadb system $FILED"
    mysqldump -A --quick | xz >"$FILED"
}

function restore_mariadb() {
    LATEST_DUMP=${1:-$(find "$BDBDIR" -name 'mariadb-dump.*' | sort | tail -1)}
    echo "[INFO] Restoring mariadb system with $LATEST_DUMP"
    xz -d "$LATEST_DUMP" | mysql
}

# Register stop
function stop_mariadb() {
    if [ "$DUMP" = "true" ];then
	# FixMe EC.
        dump_mariadb
    fi
    echo "[INFO] Stopping mariadb system"
    mysqladmin shutdown
    EC=$?
    : > "$BDBDIR/.mariadb"
    echo "[Info] Done"
    exit ${EC}
}

trap "stop_mariadb" SIGTERM SIGINT
trap "" SIGHUP

if [ -r "$MCDIR/post.sh" ];then . "$MCDIR/post.sh";fi

wait "$MARIADB_PID"
