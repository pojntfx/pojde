#!/bin/bash

# Install noVNC
apt install -y xvfb x11vnc novnc net-tools

# Install desktop
if [ "${POJDE_OPENRC}" = 'true' ]; then
    # Install fluxbox & matchbox-keyboard (XFCE4 & Onboard require systemd)
    apt install -y fluxbox x11-xserver-utils matchbox-keyboard
else
    # Install XFCE4
    apt install -y xfce4 onboard
fi

# Add temporary password
x11vnc -storepasswd changeme /etc/vncsecret

# Set screen resultion
RESOLUTION="1280x720x24"

# Create services
if [ "${POJDE_OPENRC}" = 'true' ]; then
    # Create OpenRC service for Xvfb
    cat <<EOT >/etc/init.d/xvfb
#!/sbin/openrc-run                                                                                                                                                                                                    
name=\$RC_SVCNAME
command="/usr/bin/sudo"
command_args="-u \$(cat /opt/pojde/user/user) /usr/bin/Xvfb :1 -screen 0 ${RESOLUTION} +iglx"
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
    chmod +x /etc/init.d/xvfb

    # Create OpenRC service for Fluxbox
    cat <<EOT >/etc/init.d/desktop
#!/sbin/openrc-run                                                                                                                                                                                                    
name=\$RC_SVCNAME
command="/usr/bin/sudo"
command_args='-u \$(cat /opt/pojde/user/user) sh -c "cd /home/\$(cat /opt/pojde/user/user) && DISPLAY=:1 /usr/bin/startfluxbox"'
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
    chmod +x /etc/init.d/desktop

    # Create OpenRC service for x11vnc
    cat <<EOT >/etc/init.d/x11vnc
#!/sbin/openrc-run                                                                                                                                                                                                    
name=\$RC_SVCNAME
command="/usr/bin/sudo"
command_args="-u \$(cat /opt/pojde/user/user) /usr/bin/x11vnc -display :1 -rfbauth /etc/vncsecret@\$(cat /opt/pojde/user/user) -forever"
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
    chmod +x /etc/init.d/x11vnc

    # Create OpenRC service for noVNC with the listen port set to 38003
    cat <<EOT >/etc/init.d/novnc
#!/sbin/openrc-run                                                                                                                                                                                                    
name=\$RC_SVCNAME
command="/usr/bin/sudo"
command_args="-u \$(cat /opt/pojde/user/user) /usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 38003"
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
    chmod +x /etc/init.d/novnc

    # Disable LightDM so that it doesn't take over in privileged mode
    rc-update del lightdm default
else
    # Create systemd service for Xvfb
    cat <<EOT >/usr/lib/systemd/system/xvfb@.service
[Unit]
Description=Xvfb

[Service]
Type=simple
ExecStart=/usr/bin/Xvfb :1 -screen 0 ${RESOLUTION} +iglx
Restart=always
User=%i

[Install]
WantedBy=multi-user.target
EOT

    # Create systemd service for XFCE4
    cat <<EOT >/usr/lib/systemd/system/desktop@.service
[Unit]
Description=XFCE4

[Service]
Type=simple
ExecStart=/usr/bin/startxfce4
WorkingDirectory=/home/%i
Environment="DISPLAY=:1"
Restart=always
User=%i

[Install]
WantedBy=multi-user.target
EOT

    # Create systemd service for x11vnc
    cat <<EOT >/usr/lib/systemd/system/x11vnc@.service
[Unit]
Description=x11vnc

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -display :1 -rfbauth /etc/vncsecret@%i -forever
Restart=always
User=%i

[Install]
WantedBy=multi-user.target
EOT

    # Create systemd service for noVNC with the listen port set to 38003
    cat <<EOT >/usr/lib/systemd/system/novnc@.service
[Unit]
Description=noVNC

[Service]
Type=simple
ExecStart=/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 38003
Restart=always
User=%i

[Install]
WantedBy=multi-user.target
EOT

    # Disable LightDM so that it doesn't take over in privileged mode
    systemctl disable lightdm
fi
