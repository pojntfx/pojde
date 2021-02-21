#!/bin/bash

# Display welcome message
dialog --msgbox "Welcome to pojde Next Generation! Please press ENTER to start the configuration process." 0 0

# Create preferences directory and preference file
mkdir -p /opt/pojde-ng/preferences
PREFERENCE_FILE="/opt/pojde-ng/preferences/preferences.sh"
touch ${PREFERENCE_FILE}

# If the preferences exist, source them
source ${PREFERENCE_FILE}

# Ask for new root password
echo export POJDE_NG_NEW_ROOT_PASSWORD="$(dialog --stdout --insecure --passwordbox "Enter the new root password or press enter to keep the current one:" 0 0 ${POJDE_NG_NEW_ROOT_PASSWORD})" >${PREFERENCE_FILE}
