#!/bin/bash

# Add the Docker repository
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
if [ "$(uname -m)" = 'x86_64' ]; then
    echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' >/etc/apt/sources.list.d/docker.list
else
    echo 'deb [arch=arm64] https://download.docker.com/linux/debian buster stable' >/etc/apt/sources.list.d/docker.list
fi

# Install the Docker CLI
apt update
apt install -y docker-ce-cli
