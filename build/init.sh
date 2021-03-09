#!/bin/bash

# Configure the init system
if [ "${POJDE_OPENRC}" = 'true' ]; then
    # Install OpenRC
    apt install -y openrc

    # Enable running in Docker (adapted from https://github.com/pojntfx/alpine-openrc/blob/main/Dockerfile.edge)
    sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab
    sed -i \
        -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
        -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
        -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
        -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
        -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
        -e 's/#rc_controller_cgroups=".*"/rc_controller_cgroups="NO"/g' \
        /etc/rc.conf

    # Remove unnecessary services
    rm -f /etc/init.d/{hwdrivers,modules,modules-load,modloop,cryptdisks,cryptdisks-early,hwclock.sh,keyboard-setup.sh,procps,udev}

    # Remove cgroup support
    sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh
    sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh
    rm /lib/rc/sh/rc-cgroup.sh
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
