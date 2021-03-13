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

    # Add docker-pojde-volume-setup command, which enables using volumes
    CONFIG_FILE=/etc/profile.d/docker.sh
    cat <<EOT >$CONFIG_FILE
function docker-pojde-volume-setup() {
    container_name=\$(docker inspect -f "{{.Name}}" $(hostname))
    export PWD="\$(docker volume inspect -f {{.Mountpoint}} \${container_name##/}-home-user)\${PWD##/home}"
}
EOT
    chmod +x ${CONFIG_FILE}

    # Add docker-pojde-volume-setup command to both .bashrcs
    echo ". ${CONFIG_FILE}" >>/root/.bashrc
    echo ". ${CONFIG_FILE}" >>/home/${POJDE_USERNAME}/.bashrc
}

# Refresh script
function refresh() {
    :
}
