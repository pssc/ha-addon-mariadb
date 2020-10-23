#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: mariadb+
# ==============================================================================

# We are setup for Five minutes the max
# FIXME set from Docker build?
HAA_TIMEOUT=${HAA_TIMEOUT:-"300"}
echo -n ${HAA_TIMEOUT}  > /run/s6/container_environment/HAA_TIMEOUT
# 99% of our limit
echo -n $(($HAA_TIMEOUT*990)) >/run/s6/container_environment/S6_SERVICES_GRACETIME
echo -n $(($HAA_TIMEOUT*990)) >/run/s6/container_environment/S6_KILL_FINISH_MAXTIME
