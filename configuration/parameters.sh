#!/bin/bash

# Display welcome message
dialog --msgbox "Welcome to pojde Next Generation! Please press ENTER to start the configuration process." 0 0

# Create preferences directory and preference file
PREFERENCE_FILE="/opt/pojde-ng/preferences/preferences.sh"
TMP_PREFERENCE_FILE="${PREFERENCE_FILE}.tmp"
touch ${PREFERENCE_FILE}
touch ${TMP_PREFERENCE_FILE}

# If the preferences exist, source them
source ${PREFERENCE_FILE}

# Ask for new root password
echo export "'"POJDE_NG_ROOT_PASSWORD="$(dialog --stdout --nocancel --insecure --passwordbox "Enter the new root password or press ENTER to keep the current one:" 0 0 ${POJDE_NG_ROOT_PASSWORD})""'" >${TMP_PREFERENCE_FILE}

# Ask for new username and password
echo export "'"POJDE_NG_USERNAME="$(dialog --stdout --nocancel --inputbox "Enter the new username or press ENTER to keep the current one:" 0 0 ${POJDE_NG_USERNAME})""'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_NG_PASSWORD="$(dialog --stdout --nocancel --insecure --passwordbox "Enter the new password or press ENTER to keep the current one:" 0 0 ${POJDE_NG_PASSWORD})""'" >>${TMP_PREFERENCE_FILE}

# Ask for IP domain
echo export "'"POJDE_NG_IP="$(dialog --stdout --nocancel --inputbox "Enter the new IP or press ENTER to keep the current one:" 0 0 ${POJDE_NG_IP})""'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_NG_DOMAIN="$(dialog --stdout --nocancel --inputbox "Enter the new domain or press ENTER to keep the current one:" 0 0 ${POJDE_NG_DOMAIN})""'" >>${TMP_PREFERENCE_FILE}

# Ask for SSH key URL; get from GitHub by default
if [ -z "${POJDE_NG_SSH_KEY_URL}" ]; then
    source ${TMP_PREFERENCE_FILE} # In case the user has changed their username, reload it

    export POJDE_NG_SSH_KEY_URL="https://github.com/${POJDE_NG_USERNAME}.keys"
fi
echo export "'"POJDE_NG_SSH_KEY_URL="$(dialog --stdout --nocancel --inputbox "Enter a link to your SSH keys or press ENTER to keep the current one:" 0 0 ${POJDE_NG_SSH_KEY_URL})""'" >>${TMP_PREFERENCE_FILE}

# Ask for confirmation
dialog --yesno 'Are you sure you want apply the configuration?' 0 0 || exit 1

# Write to configuration file if accepted
mv ${TMP_PREFERENCE_FILE} ${PREFERENCE_FILE}
