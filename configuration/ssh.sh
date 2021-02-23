#!/bin/bash

# Read configuration file
source /opt/pojde-ng/preferences/preferences.sh

# Add the user's SSH keys to authorized_keys
CONFIG_DIR=/root/.ssh
mkdir -m 700 -p ${CONFIG_DIR}
curl -L "${POJDE_NG_SSH_KEY_URL}" | tee ${CONFIG_DIR}/authorized_keys
chmod 600 ${CONFIG_DIR}/authorized_keys

# Enable & restart the services
if [ "${POJDE_NG_SYSVINIT}" = 'true' ]; then
    ln -sf /etc/init.d/dropbear /etc/rc3.d/dropbear
    service dropbear restart
fi
