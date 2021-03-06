#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Set up Git pull strategy, branch, email and password
    su - $POJDE_USERNAME -c "git config --global pull.rebase false"
    su - $POJDE_USERNAME -c "git config --global init.defaultBranch main"
    su - $POJDE_USERNAME -c "git config --global user.email \"${POJDE_EMAIL}\""
    su - $POJDE_USERNAME -c "git config --global user.name \"${POJDE_FULL_NAME}\""
}

# Refresh script
function refresh() {
    :
}
