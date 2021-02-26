#!/bin/bash

# Run the official installation script
curl -fsSL https://code-server.dev/install.sh | sh -s -

# Change the listen port to 38001
mkdir -p /opt/pojde-ng/code-server
CONFIG_FILE=/opt/pojde-ng/code-server/code-server.yaml
cat <<EOT >$CONFIG_FILE
bind-addr: 127.0.0.1:38001
auth: none
EOT

# We'll use Open-VSX
SERVICE_URL=https://open-vsx.org/vscode/gallery
ITEM_URL=https://open-vsx.org/vscode/item

# Create services
if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
    # Create OpenRC service
    cat <<EOT >/etc/init.d/code-server
#!/sbin/openrc-run                                                                                                                                                                                                    
name=\$RC_SVCNAME
command="/usr/bin/sudo"
command_args='-u \$(cat /opt/pojde-ng/user/user) bash -i -c "SERVICE_URL=${SERVICE_URL} ITEM_URL=${ITEM_URL} /usr/bin/code-server --config $CONFIG_FILE"'
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
    chmod +x /etc/init.d/code-server
else
    # Change the systemd service to use the new config file
    sed -i "s@ExecStart=/usr/bin/code-server@ExecStart=/bin/bash -i -c \"/usr/bin/code-server --config $CONFIG_FILE\"@g" /usr/lib/systemd/system/code-server@.service

    # Use Open-VSX as the default marketplace
    sed -i "s@Restart=always@Restart=always\nEnvironment=SERVICE_URL=${SERVICE_URL}\nEnvironment=ITEM_URL=${ITEM_URL}@g" /usr/lib/systemd/system/code-server\@.service
fi
