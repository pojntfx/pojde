#!/bin/bash

# Read configuration file
source /opt/pojde-ng/preferences/preferences.sh

# Change the password to the new value
CONFIG_FILE=/opt/pojde-ng/code-server/code-server.yaml
cat <<EOT >$CONFIG_FILE
bind-addr: 127.0.0.1:38001
auth: password
password: "${POJDE_NG_PASSWORD}"
EOT

# Enable & restart the service
systemctl enable "code-server@${POJDE_NG_USERNAME}"
systemctl restart "code-server@${POJDE_NG_USERNAME}"
