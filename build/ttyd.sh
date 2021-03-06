#!/bin/bash

# Download the binary
VERSION="1.6.3"
curl -L -o /usr/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/${VERSION}/ttyd.$(uname -m)
chmod +x /usr/bin/ttyd

# Create services
if [ "${POJDE_OPENRC}" = 'true' ]; then
    # Create OpenRC service with the listen port set to 38002
    cat <<EOT >/etc/init.d/ttyd
#!/sbin/openrc-run                                                                                                                                                                                                    
name=\$RC_SVCNAME
command="/usr/bin/sudo"
command_args='-u \$(cat /opt/pojde/user/user) sh -c "cd /home/\$(cat /opt/pojde/user/user) && /usr/bin/ttyd -i lo -p 38002 -c \$(cat /opt/pojde/ttyd/env) bash"'
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
    chmod +x /etc/init.d/ttyd
else
    # Create systemd service with the listen port set to 38002
    cat <<EOT >/usr/lib/systemd/system/ttyd@.service
[Unit]
Description=ttyd

[Service]
Type=simple
EnvironmentFile=/opt/pojde/ttyd/env
ExecStart=/usr/bin/ttyd -i lo -p 38002 -c \${USERNAME_PASSWORD} bash
WorkingDirectory=/home/%i
Restart=always
User=%i

[Install]
WantedBy=multi-user.target
EOT
fi
