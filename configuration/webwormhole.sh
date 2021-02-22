#!/bin/bash

# Display download instructions
dialog --msgbox "" 0 0 # This is a bit of a hack; `docker exec -it` seems to automatically answer the first dialog, this dummy prevents that
dialog --msgbox "Configuration almost completed! One last thing: Please press ENTER and then click the generated link or scan the QR code to download the CA certificate." 0 0

# Send the root CA certificate
CA_FILE=/opt/pojde-ng/ca/ca.pem
ww send ${CA_FILE}

# Display link to next steps
dialog --msgbox "Successfully downloaded CA certificate! Please continue to https://github.com/pojntfx/pojde-ng for the next steps." 0 0
