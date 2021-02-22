#!/bin/bash

# Read configuration file
source /opt/pojde-ng/preferences/preferences.sh

# Change the password to the new value
mkdir -p /opt/pojde-ng/ttyd
CONFIG_FILE=/opt/pojde-ng/ttyd/flags.sh
cat <<EOT >$CONFIG_FILE
USERNAME_PASSWORD='${POJDE_NG_USERNAME}:${POJDE_NG_PASSWORD}'
EOT

# Enable & restart the service
systemctl enable "ttyd@${POJDE_NG_USERNAME}"
systemctl restart "ttyd@${POJDE_NG_USERNAME}"
