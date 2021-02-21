#!/bin/bash

# Run the official installation script
curl -fsSL https://code-server.dev/install.sh | sh -s -

# Change the listen port to 38001
mkdir -p /opt/pojde-ng/code-server
CONFIG_FILE=/opt/pojde-ng/code-server/code-server.yaml
cat <<EOT >$CONFIG_FILE
bind-addr: 127.0.0.1:38001
auth: none
EOT

# Change the systemd service to use the new config file
sed -i "s@ExecStart=/usr/bin/code-server@ExecStart=/usr/bin/code-server --config $CONFIG_FILE@g" /usr/lib/systemd/system/code-server@.service
