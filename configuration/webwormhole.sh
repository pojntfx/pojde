#!/bin/bash

# Section title
SECTION_TITLE="pojde Finishing Up"

# Upgrade script
function upgrade() {
    # This is a bit of a hack; `docker exec -it` seems to automatically answer the first dialog, this dummy prevents that
    dialog --backtitle "${SECTION_TITLE}" --msgbox "" 0 0

    # Ask the user if they wish to download their CA certificate
    CA_FILE=/opt/pojde/ca/ca.pem

    # Finish up
    selected_action=""
    while [ "${selected_action}" != "skip" ]; do
        # Read next action
        available_actions=(
            skip "Continue"
            download "Download cert as file"
            display "Display cert contents"
        )
        selected_action="$(dialog --backtitle "${SECTION_TITLE}" --stdout --nocancel --menu 'Almost done! Would you like to download your CA certificate for encrypted access to pojde?' 0 0 0 "${available_actions[@]}")"

        # Download or display the CA certificate
        if [ "${selected_action}" = "download" ]; then
            # Display download instructions
            dialog --backtitle "${SECTION_TITLE}" --msgbox "Please press ENTER and then click the generated link or scan the QR code to download the CA certificate." 0 0

            # Send the root CA certificate
            ww send "${CA_FILE}"
        elif [ "${selected_action}" = "display" ]; then
            # Clear the screen
            clear

            # Show the ca cert
            cat "${CA_FILE}"

            # Newline
            echo

            # Continue with ENTER
            read -p "Press ENTER to continue"
        fi
    done

    # Display final success message
    dialog --backtitle "${SECTION_TITLE}" --msgbox "Configuration successfully completed! Please continue to https://github.com/pojntfx/pojde#Usage for the next steps." 0 0
}

# Refresh script
function refresh() {
    :
}
