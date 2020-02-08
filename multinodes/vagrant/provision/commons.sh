#!/bin/bash

set -eux -o pipefail

# No FW
systemctl disable ufw.service


apt-get update -y -qq

## Python 2 is required next to Python 3
apt-get install -y python-minimal

# Disable AppArmor at all
systemctl stop apparmor || true
systemctl disable apparmor || true
apt-get remove --purge -y -qq apparmor apparmor-profiles
