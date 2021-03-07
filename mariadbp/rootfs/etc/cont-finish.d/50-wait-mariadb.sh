#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: mariadb+ addon 
# Starts the home assisant intergration
# ==============================================================================
BDBDIR=${BDBDIR:-"/backup"}
. /opt/mariadb-support/lib/mariadbio.sh

function main() {
  local WC=0
  bashio::log.debug "Waiting for mariadb to finish..."
  while [[ ! -r /tmp/.mariadb_done ]];do
    WC=$((WC+1)) 
    sleep 1
  done
  bashio::log.info "Waited ${WC} for mariadb to finish..."
}

main
# vim: ft=sh
