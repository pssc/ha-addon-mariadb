#!/usr/bin/with-contenv bashio
# ==============================================================================
# Community Hass.io Add-ons
# Set up env from ha addon name.
# ==============================================================================

HAA_NAME=$(hostname -s | sed 's/.*-//')
echo -n ${HAA_NAME} >/run/s6/container_environment/HAA_NAME

exit 0
