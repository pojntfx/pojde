#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Add Docker group and add user to it
    groupadd docker
    usermod -aG docker ${POJDE_USERNAME}

    # Fix access from VSCode (FIXME: This should be more fine-grained)
    chmod 777 /var/run/docker.sock
}

# Refresh script
function refresh() {
    :
}
