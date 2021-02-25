#!/bin/bash

# Read configuration file
. /opt/pojde-ng/preferences/preferences.sh

# Add the user's SSH keys to authorized_keys
CONFIG_DIR=/root/.ssh
mkdir -m 700 -p ${CONFIG_DIR}
curl -L "${POJDE_NG_SSH_KEY_URL}" | tee ${CONFIG_DIR}/authorized_keys
chmod 600 ${CONFIG_DIR}/authorized_keys

# Enable & restart the services
if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
    rc-service dropbear restart
    rc-update add dropbear default
fi
