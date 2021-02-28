#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Add Docker group and add user to it
    groupadd docker
    usermod -aG docker ${POJDE_NG_USERNAME}
}

# Refresh script
function refresh() {
    :
}
