#!/bin/bash

# Upgrade script
function upgrade() {
    # Upgrade pojdectl
    curl https://raw.githubusercontent.com/pojntfx/pojde/main/bin/pojdectl | bash -s -- upgrade-pojdectl
}

# Refresh script
function refresh() {
    :
}
