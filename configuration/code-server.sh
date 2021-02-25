#!/bin/bash

# Read configuration file
. /opt/pojde-ng/preferences/preferences.sh

# Change the password to the new value
CONFIG_FILE=/opt/pojde-ng/code-server/code-server.yaml
cat <<EOT >$CONFIG_FILE
bind-addr: 127.0.0.1:38001
auth: password
password: "${POJDE_NG_PASSWORD}"
EOT

# Enable & restart the services
if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
    rc-service code-server restart
    rc-update add code-server default
else
    systemctl enable "code-server@${POJDE_NG_USERNAME}"
    systemctl restart "code-server@${POJDE_NG_USERNAME}"
fi
