#!/bin/bash

# Install Cockpit
apt install -y cockpit

# Change the listen port to 38000
mkdir -p /etc/systemd/system/cockpit.socket.d
cat <<EOT >/etc/systemd/system/cockpit.socket.d/listen.conf
[Socket]
ListenStream=
ListenStream=38000
EOT

# Enable CORS
cat <<EOT >/etc/cockpit/cockpit.conf
[WebService]
AllowUnencrypted = true
Origins = http://localhost:38000
EOT
