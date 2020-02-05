#!/bin/bash
set -eux -o pipefail

## This script provision the OpenIO Docker Compose Stack on Ubuntu Bionic (LTS - 18.04)

## Install Docker on Ubuntu - https://docs.docker.com/install/linux/docker-ce/ubuntu/

apt-get update -qq
apt-get remove -y docker docker-engine docker.io containerd runc

apt-get install -y -qq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

apt-get update -qq
apt-get upgrade -y -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io

usermod -aG docker ubuntu

systemctl restart docker
systemctl enable docker

## Install Docker-Compose
curl -sSfL https://github.com/docker/compose/releases/download/1.25.4/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
docker-compose version

## DNS setup
HOST_ENTRY_OIO='192.168.100.10   s3.open.io'
grep "${HOST_ENTRY_OIO}" /etc/hosts || echo "${HOST_ENTRY_OIO}" >> /etc/hosts

HOST_ENTRY_WEBAPP='192.168.100.20   webapp.open.io'
grep "${HOST_ENTRY_WEBAPP}" /etc/hosts || echo "${HOST_ENTRY_WEBAPP}" >> /etc/hosts

## Start Services
cd /vagrant/openio
docker-compose up -d
