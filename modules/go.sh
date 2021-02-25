#!/bin/bash

# Read configuration file
source /opt/pojde-ng/preferences/preferences.sh

# Fetch Go binary package
GO_VERSION=1.16
if [ "$(uname -m)" = 'x86_64' ]; then
    curl -L -o /tmp/go.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
else
    curl -L -o /tmp/go.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-arm64.tar.gz
fi

# Extract the package to /usr/local
tar -C /usr/local -xzf /tmp/go.tar.gz

# Remove the extracted package
rm /tmp/go.tar.gz

# Add Go to PATH using profile
echo 'export PATH=$PATH:/usr/local/go/bin' >/etc/profile.d/go.sh
chmod +x /etc/profile.d/go.sh

# Add Go to both .bashrcs
echo 'source /etc/profile.d/go.sh' >>/root/.bashrc
echo 'source /etc/profile.d/go.sh' >>/home/${POJDE_NG_USERNAME}/.bashrc
source /root/.bashrc

# Install the Go VSCode extension
su ${POJDE_NG_USERNAME}
code-server --install-extension 'golang.Go'

# Download the Go Jupyter Kernel
GOPHER_NOTES_VERSION=0.7.1
env GO111MODULE=on go get github.com/gopherdata/gophernotes
mkdir -p /home/${POJDE_NG_USERNAME}/.local/share/jupyter/kernels/gophernotes
cd /home/${POJDE_NG_USERNAME}/.local/share/jupyter/kernels/gophernotes
cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@v${GOPHER_NOTES_VERSION}/kernel/* "."
chmod +w ./kernel.json
sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" <kernel.json.in >kernel.json

# Become root again
exit 0
