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
