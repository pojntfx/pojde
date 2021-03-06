#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Create config file
    mkdir -p /opt/pojde/ttyd
    CONFIG_FILE=/opt/pojde/ttyd/env

    # Enable & restart the services
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        # Change the password to the new value
        cat <<EOT >$CONFIG_FILE
'${POJDE_USERNAME}:${POJDE_PASSWORD}'
EOT

        rc-service ttyd restart
        rc-update add ttyd default
    else
        # Change the password to the new value
        cat <<EOT >$CONFIG_FILE
USERNAME_PASSWORD='${POJDE_USERNAME}:${POJDE_PASSWORD}'
EOT

        systemctl enable "ttyd@${POJDE_USERNAME}"
        systemctl restart "ttyd@${POJDE_USERNAME}"
    fi
}

# Refresh script
function refresh() {
    :
}
