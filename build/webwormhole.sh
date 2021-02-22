#!/bin/bash

# Download the binary & add it to the PATH
VERSION="latest"
if [ $(uname -m) = 'x86_64' ]; then
    curl -L -o /usr/bin/ww https://github.com/pojntfx/webwormhole-binaries/releases/download/${VERSION}/ww.linux-amd64
else
    curl -L -o /usr/bin/ww https://github.com/pojntfx/webwormhole-binaries/releases/download/${VERSION}/ww.linux-arm64
fi
chmod +x /usr/bin/ww
