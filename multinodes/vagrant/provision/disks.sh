#!/bin/bash

set -eux -o pipefail

## Open IO Installation preparation instructions
## From https://docs.openio.io/latest/source/sandbox-guide/multi_nodes_install.html
## This script expect theto be run on Ubuntu 18.04

## Arguments:
## - $1: number of disks to format and mount in XFS

NB_DISKS=${1:-1}

## Check if volume is already formatted in XFS or not
for NUM_DISK in $(seq "${NB_DISKS}")
do
    mkdir -p "/mnt/disk${NUM_DISK}"
    DISK="/dev/sd$(echo $((NUM_DISK+98)) | awk '{printf("%c",$1)}')"
    blkid "${DISK}" || (
        mkfs.xfs "${DISK}"
    )

    grep "${DISK}" /etc/fstab || (
        echo "$(blkid "${DISK}" | awk '{print$2}' | sed -e 's/"//g') /mnt/disk${NUM_DISK}   xfs   noatime,nobarrier   0   0" >> /etc/fstab
    )
done

mount -a
