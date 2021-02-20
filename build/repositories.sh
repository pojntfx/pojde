#!/bin/bash

# Add the backports repository
echo 'deb http://deb.debian.org/debian buster-backports main' >/etc/apt/sources.list.d/backports.list

# Upgrade the system
apt update
apt upgrade -y
