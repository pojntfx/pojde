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
    xfce4
    x11vnc
    novnc
)

for service in "${services[@]}"; do
    systemctl enable "${service}@${POJDE_NG_USERNAME}"
done

for service in "${services[@]}"; do
    systemctl restart "${service}@${POJDE_NG_USERNAME}"
done
