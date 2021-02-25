#!/bin/bash

# Read configuration file
. /opt/pojde-ng/preferences/preferences.sh

# Set up Git pull strategy, branch, email and password
su - $POJDE_NG_USERNAME -c "git config --global pull.rebase false"
su - $POJDE_NG_USERNAME -c "git config --global init.defaultBranch main"
su - $POJDE_NG_USERNAME -c "git config --global user.email \"${POJDE_NG_EMAIL}\""
su - $POJDE_NG_USERNAME -c "git config --global user.name \"${POJDE_NG_FULL_NAME}\""
