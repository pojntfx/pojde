#!/bin/bash

# Upgrade script
function upgrade() {
    # Cache packages
    CONFIG_FILE=/etc/apt/apt.conf.d/01-custom-local
    cat <<EOT >$CONFIG_FILE
Binary::apt::APT::Keep-Downloaded-Packages "true";
EOT

    # Remove the Docker overrides
    rm -f /etc/apt/apt.conf.d/{docker-autoremove-suggests,docker-clean,docker-gzip-indexes,docker-no-languages}
}

# Refresh script
function refresh() {
    # Remove cached packages
    rm -f /var/cache/apt/archives/*.deb
}
