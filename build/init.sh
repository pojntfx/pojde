#!/bin/bash

# Configure the init system
if [ "${POJDE_NG_SYSVINIT}" = 'true' ]; then
    # Install SysVinit
    apt install -y sysvinit-core
else
    # Install systemd
    apt install -y systemd systemd-sysv

    # Remove unnecessary systemd config files (see https://github.com/j8r/dockerfiles/blob/master/systemd/debian/10.Dockerfile)
    rm -f /lib/systemd/system/multi-user.target.wants/* \
        /etc/systemd/system/*.wants/* \
        /lib/systemd/system/local-fs.target.wants/* \
        /lib/systemd/system/sockets.target.wants/*udev* \
        /lib/systemd/system/sockets.target.wants/*initctl* \
        /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
        /lib/systemd/system/systemd-update-utmp*
fi