#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Set new root password
    echo "root:${POJDE_ROOT_PASSWORD}" | chpasswd

    # Create new user and add them to the wheel group
    addgroup --system wheel
    useradd -m "${POJDE_USERNAME}"
    sed -i 's/#auth required pam_wheel.so/auth required pam_wheel.so/g' /etc/pam.d/su
    adduser "${POJDE_USERNAME}" wheel
    adduser "${POJDE_USERNAME}" sudo

    # Change the password for the new user
    echo "${POJDE_USERNAME}:${POJDE_PASSWORD}" | chpasswd

    # Use bash as the default shell for the new user
    chsh -s /bin/bash "${POJDE_USERNAME}"

    # Set up transfer directory
    mkdir -p /home/${POJDE_USERNAME}/Documents
    ln -sf /transfer /home/${POJDE_USERNAME}/Documents
    chown -R ${POJDE_USERNAME} /home/${POJDE_USERNAME}/Documents

    if [ "${POJDE_OPENRC}" = 'true' ]; then
        # Persist the username for OpenRC services
        mkdir -p /opt/pojde/user
        CONFIG_FILE=/opt/pojde/user/user
        echo "${POJDE_USERNAME}" >$CONFIG_FILE
    fi
}

# Refresh script
function refresh() {
    :
}
