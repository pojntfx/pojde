#!/bin/bash

# Read versions
. /opt/pojde/versions.sh

# Download the binary & add it to the PATH
VERSION="${WEBWORMHOLE_VERSION}"
curl -L -o /usr/bin/ww https://github.com/pojntfx/webwormhole-binaries/releases/download/${VERSION}/ww.linux-$(uname -m)
chmod +x /usr/bin/ww
