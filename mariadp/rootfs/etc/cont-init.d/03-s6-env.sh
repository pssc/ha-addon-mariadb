#!/usr/bin/with-contenv bash
# ==============================================================================
# Community Hass.io Add-ons: 
# ==============================================================================

echo -n 179000 >/run/s6/container_environment/S6_SERVICES_GRACETIME
#echo -n 100000 >/run/s6/env-stage2/S6_SERVICES_GRACETIME
#echo -n 100000 >/run/s6/env-stage3/S6_SERVICES_GRACETIME
#echo -n 100000 >/run/s6/container_environment/S6_KILL_FINISH_MAXTIME

