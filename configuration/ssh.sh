#!/bin/bash

# Read configuration file
source /opt/pojde-ng/preferences/preferences.sh

# Add the user's SSH keys to authorized_keys
mkdir -m 700 -p /root/.ssh
curl -L "${POJDE_NG_SSH_KEY_URL}" | tee /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
