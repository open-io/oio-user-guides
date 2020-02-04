#!/bin/bash
set -eux -o pipefail

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

curl -sfL https://get.k3s.io | sh -

sleep 5

chmod -R 0644 /etc/rancher/k3s/k3s.yaml

curl -L "https://github.com/docker/compose/releases/download/1.25.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

echo '172.17.0.1   s3.open.io open.io' >> /etc/hosts

# /usr/local/bin/kubectl completion bash > /etc/bash_completion.d/kubectl
# /usr/local/bin/kubectl get pod --all-namespaces
# /usr/local/bin/kubectl create -f /vagrant/kubernetes/s3-secret.yaml
# /usr/local/bin/kubectl create -f /vagrant/kubernetes/provisioner.yaml
# /usr/local/bin/kubectl create -f /vagrant/kubernetes/attacher.yaml
# /usr/local/bin/kubectl create -f /vagrant/kubernetes/csi-s3.yaml
