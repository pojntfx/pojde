#!/bin/bash

# Install OpenSSH server
apt install -y openssh-server

# Enable TCP forwarding
sed -i 's/#AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

# Change listen port to 38022
sed -i 's/#Port 22/Port 38022/g' /etc/ssh/sshd_config

# Only listen on loopback
sed -i 's/#ListenAddress 0.0.0.0/ListenAddress 127.0.0.1/g' /etc/ssh/sshd_config
