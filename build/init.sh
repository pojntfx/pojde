#!/bin/bash

# Configure the init system
if [ "${POJDE_NG_SYSVINIT}" = 'true' ]; then
    # Install SysVinit
    apt install -y openrc

    # Enable running in Docker (see https://github.com/pojntfx/alpine-openrc/blob/main/Dockerfile.edge)
    sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab
    sed -i -e 's/#rc_sys=".*"/rc_sys="docker"/g' -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' /etc/rc.conf

    rm -f /etc/init.d/hwdrivers \
        /etc/init.d/hwclock \
        /etc/init.d/hwdrivers \
        /etc/init.d/modules \
        /etc/init.d/modules-load \
        /etc/init.d/modloop

    sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh
    sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh
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
