#!/bin/bash

# Download the binary & add it to the PATH
VERSION="latest"
curl -L -o /usr/bin/ww https://github.com/pojntfx/webwormhole-binaries/releases/download/${VERSION}/ww.linux-$(uname -m)
chmod +x /usr/bin/ww
