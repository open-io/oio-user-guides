#!/bin/bash

set -eux -o pipefail
NB_DISK=${1:-4}
SIZE=${2:-"1G"}

# Fake disks
for i in $( seq 0 $(($NB_DISK-1)) ); do
  fallocate -l ${SIZE} disk${i}.img
  parted -a optimal disk${i}.img -s mklabel gpt unit TB mkpart primary 0% 100%
  mkfs.xfs -f -L FAKEDISK-${i} disk${i}.img
  losetup -f disk${i}.img
done

loop=0
for i in $(blkid  | grep "FAKEDISK" | awk -F\: '{print $2}' | awk '{print $2}' | sed 's/UUID="\(.*\)"/\1/'); do
  mkdir /mnt/disk${loop}
  echo "UUID=${i} /mnt/disk${loop} xfs defaults,noatime,noexec 0 0" >> /etc/fstab
  loop=$(($loop+1))
done

mount -a

# Allow the use of "ansible_ssh_pass"
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd.service
