#!/usr/bin/env bash
# ==============================================================================
# Home Assistant Community Add-ons: Bashio
# Bashio is an bash function library for use with Home Assistant add-ons.
#
# It contains a set of commonly used operations and can be used
# to be included in add-on scripts to reduce code duplication across add-ons.
# ==============================================================================
set -o errexit  # Exit script when a command exits with non-zero status
set -o errtrace # Exit on error inside any functions or sub-shells
set -o nounset  # Exit script on use of an undefined variable
set -o pipefail # Return exit status of the last command in the pipe that failed

# ==============================================================================
# GLOBALS
# ==============================================================================

# version number
readonly MARIAIO_VERSION="0.0.1"

# Stores the location of this library
readonly __MARIAIO_LIB_DIR=$(dirname "${BASH_SOURCE[0]}")

function dump_mariadb() {
    local DDDIR=${1:-$BDBDIR}
    local FILEDL=${2:-"mariadb-dump.$(date -Iseconds).xz"}
    local FILEDT="${DDDIR}/.$FILEDL"
    local FILED="${DDDIR}/$FILEDL"
    echo "$(date -Iseconds) [INFO] Dumping mariadb system ${FILED}"
    #if? non zero exit...
    if mysqldump ${MDDUMPOPTS:--A --opt} | xz ${XZDUMPOPTS:--0 -T0} >"${FILEDT}";then
      sync
      if [ -s "${FILEDT}" ];then
            mv "${FILEDT}" "${FILED}"
	    sync
            echo "$(date -Iseconds) [INFO] mysqldump ${FILED} / size: $(du ${FILED} | cut -f 1)"
	    return 0
      fi
    else
      EC=$?
      echo "$(date -Iseconds) [ERROR] mysqldump ${FILED} / xz exit ($EC) size: $(du ${FILET} | cut -f 1)"
    fi
    return 1
}

function restore_mariadb() {
    # FIXME 
    local LATEST_DUMP=${1:-$(find -maxdepth ${DEPTH_DUMP:-1} "/data/dump" "${BDBDIR}" -name 'mariadb-dump.*' | sort -t . -k 2| tail -1)}
    echo "$(date -Iseconds) [INFO] Restoring mariadb system with ${LATEST_DUMP}"
    if [ -r "${LATEST_DUMP}" ];then
       # check? integrity of dump
       xzcat "${LATEST_DUMP}" | mysql
       # FIXME
    fi
    echo "$(date -Iseconds) [INFO] Restored"
}

function wait_mariadb() {
    local WC=0
    # Wait until DB is running
    while ! mysql -e "" 2> /dev/null; do
       sleep 1
       WC=$(($WC+1))
       if [ "$WC" -gt "$WAITS" ];then exit 2;fi
    done
    echo "[INFO] Waited $WC counts for mariadb"
}
