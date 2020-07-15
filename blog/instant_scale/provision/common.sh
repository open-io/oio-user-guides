#!/bin/bash

set -eux -o pipefail

# No firewall
systemctl stop firewalld.service
systemctl disable firewalld.service

# No SELinux
yum install libselinux-python -y
sed -i -e 's@SELINUX=.*@SELINUX=disabled@' /etc/selinux/config
setenforce 0

# install iproute, net-tools
yum install iproute net-tools wget -y


