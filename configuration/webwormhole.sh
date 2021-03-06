#!/bin/bash

# Upgrade script
function upgrade() {
    # This is a bit of a hack; `docker exec -it` seems to automatically answer the first dialog, this dummy prevents that
    dialog --msgbox "" 0 0

    # Ask the user if they wish to download their CA certificate
    CA_FILE=/opt/pojde/ca/ca.pem
    dialog --yesno 'Almost done! Would you like to download your CA certificate for encrypted access to pojde?' 0 0 && export POJDE_DOWNLOAD_CA=true || export POJDE_DOWNLOAD_CA=false

    # Download the CA certificate if selected
    if [ "${POJDE_DOWNLOAD_CA}" = 'true' ]; then
        # Display download instructions
        dialog --msgbox "Please press ENTER and then click the generated link or scan the QR code to download the CA certificate." 0 0

        # Send the root CA certificate
        ww send ${CA_FILE}
    fi

    # Display final success message
    dialog --msgbox "Configuration successfully completed! Please continue to https://github.com/pojntfx/pojde#Usage for the next steps." 0 0
}

# Refresh script
function refresh() {
    :
}
