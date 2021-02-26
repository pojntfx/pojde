#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Change the password to the new value
    CONFIG_FILE="/etc/vncsecret@${POJDE_NG_USERNAME}"
    x11vnc -storepasswd ${POJDE_NG_PASSWORD} $CONFIG_FILE
    chown "${POJDE_NG_USERNAME}" $CONFIG_FILE

    # These are the services that will need to be managed
    services=(
        xvfb
        desktop
        x11vnc
        novnc
    )

    # Enable & restart the services
    if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
        # Generate initial config files by starting Fluxbox once without an X server
        sudo -u ${POJDE_NG_USERNAME} startfluxbox || echo "Generated Fluxbox config files"

        # Enable left mouse button click for menu on desktop
        sed -i '1s/^/\OnDesktop Mouse1\ \:RootMenu\n/' /home/${POJDE_NG_USERNAME}/.fluxbox/keys

        # Add On-Screen Keyboard menu option
        echo '?package(bash):needs="text" section="Accessibility" title="On-Screen Keyboard" command="/usr/bin/matchbox-keyboard"' >/usr/share/menu/matchbox-keyboard

        # Update menus
        update-menus

        for service in "${services[@]}"; do
            rc-update add "${service}" default
            rc-service "${service}" restart
        done
    else
        for service in "${services[@]}"; do
            systemctl enable "${service}@${POJDE_NG_USERNAME}"
            systemctl restart "${service}@${POJDE_NG_USERNAME}"
        done
    fi
}

# Refresh script
function refresh() {
    :
}
