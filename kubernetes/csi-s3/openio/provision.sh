#!/bin/bash
set -eux -o pipefail

## Install Docker on CentOS

yum update -y

yum install -y \
  device-mapper-persistent-data \
  lvm2 \
  yum-utils

yum-config-manager -y --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum install -y \
  containerd.io \
  docker-ce \
  docker-ce-cli
  

systemctl start docker
systemctl enable docker

systemctl stop firewalld || true
systemctl disable firewalld || true

systemctl stop iptables || true
systemctl disable iptables || true

## Install Docker-Compose
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## Network setup
echo '172.17.0.1   s3.open.io open.io' >> /etc/hosts # Self IP is docker0 to reach compose services

## Start Services
cd /vagrant/openio
docker-compose up -d
