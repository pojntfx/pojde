#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Create config file
    mkdir -p /opt/pojde-ng/ttyd
    CONFIG_FILE=/opt/pojde-ng/ttyd/env

    # Enable & restart the services
    if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
        # Change the password to the new value
        cat <<EOT >$CONFIG_FILE
'${POJDE_NG_USERNAME}:${POJDE_NG_PASSWORD}'
EOT

        rc-service ttyd restart
        rc-update add ttyd default
    else
        # Change the password to the new value
        cat <<EOT >$CONFIG_FILE
USERNAME_PASSWORD='${POJDE_NG_USERNAME}:${POJDE_NG_PASSWORD}'
EOT

        systemctl enable "ttyd@${POJDE_NG_USERNAME}"
        systemctl restart "ttyd@${POJDE_NG_USERNAME}"
    fi
}

# Refresh script
function refresh() {
    :
}
