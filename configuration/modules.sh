#!/bin/bash

# Read configuration file
. /opt/pojde-ng/preferences/preferences.sh

# Run the enabled modules' scripts
MODULE_DIR=/opt/pojde-ng/modules/
for module in "${POJDE_NG_MODULES}"; do
    # Run root script
    . /opt/pojde-ng/modules/${module}.sh
    as_root

    # Run user script
    for module in "${POJDE_NG_MODULES}"; do
        sudo -u ${POJDE_NG_USERNAME} bash -i -c "cd && . /opt/pojde-ng/modules/${module}.sh && as_user"
    done
done
