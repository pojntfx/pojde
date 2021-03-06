#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Run the enabled modules' scripts
    MODULE_DIR=/opt/pojde/modules/
    for module in $POJDE_MODULES; do
        # Run root script
        . /opt/pojde/modules/${module}.sh
        as_root

        # Run user script
        sudo -u ${POJDE_USERNAME} bash -i -c "cd && . /opt/pojde/modules/${module}.sh && as_user"
    done
}

# Refresh script
function refresh() {
    :
}
