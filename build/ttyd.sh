#!/bin/bash

# Download the binary
VERSION="1.6.3"
curl -L -o /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/${VERSION}/ttyd.$(uname -m)
chmod +x /usr/bin/ttyd

# Create systemd service with the listen port set to 3002
cat <<EOT >/usr/lib/systemd/system/ttyd.service
[Unit]
Description=ttyd

[Service]
Type=simple
ExecStart=/usr/bin/ttyd -i lo -p 3002 bash

[Install]
WantedBy=multi-user.target
EOT
