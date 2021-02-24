#!/bin/bash

# Read configuration file
source /opt/pojde-ng/preferences/preferences.sh

# Set new root password
echo "root:${POJDE_NG_ROOT_PASSWORD}" | chpasswd

# Create new user and add them to the wheel group
addgroup --system wheel
useradd -m "${POJDE_NG_USERNAME}"
sed -i 's/#auth required pam_wheel.so/auth required pam_wheel.so/g' /etc/pam.d/su
adduser "${POJDE_NG_USERNAME}" wheel
adduser "${POJDE_NG_USERNAME}" sudo

# Change the password for the new user
echo "${POJDE_NG_USERNAME}:${POJDE_NG_PASSWORD}" | chpasswd

# Use bash as the default shell for the new user
chsh -s /bin/bash "${POJDE_NG_USERNAME}"

if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
    # Persist the username for OpenRC services
    mkdir -p /opt/pojde-ng/user
    CONFIG_FILE=/opt/pojde-ng/user/user
    echo "${POJDE_NG_USERNAME}" >$CONFIG_FILE
fi
