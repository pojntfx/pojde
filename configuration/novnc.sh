#!/bin/bash

# Read configuration file
source /opt/pojde-ng/preferences/preferences.sh

# Change the password to the new value
CONFIG_FILE="/etc/vncsecret@${POJDE_NG_USERNAME}"
x11vnc -storepasswd ${POJDE_NG_PASSWORD} $CONFIG_FILE
chown "${POJDE_NG_USERNAME}" $CONFIG_FILE

# Enable & restart the services
services=(
    xvfb
    desktop
    x11vnc
    novnc
)

if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
    for service in "${services[@]}"; do
        rc-update add "${service}" default
        rc-service "${service}" restart
    done
else
    for service in "${services[@]}"; do
        systemctl enable "${service}@${POJDE_NG_USERNAME}"
        systemctl restart "${service}@${POJDE_NG_USERNAME}"
    done
fi
