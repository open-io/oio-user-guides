#!/bin/bash
set -eux -o pipefail

## Install k3s
curl -sfL https://get.k3s.io | sh -
counter=0
max_retries=60
wait_time=2
until [ "${counter}" -ge "${max_retries}" ]
do
    if ls /etc/rancher/k3s/k3s.yaml 2>/dev/null
    then
        break
    fi
    sleep "${wait_time}"
    counter=$((counter+1))
done
[ "${counter}" -lt "${max_retries}" ]

# Allow non root user to use the config
cp /etc/rancher/k3s/k3s.yaml /vagrant/k3s-config.yaml
chmod 0644 /vagrant/k3s-config.yaml

## DNS setup
HOST_ENTRY_OIO='192.168.100.10   s3.open.io'
grep "${HOST_ENTRY_OIO}" /etc/hosts || echo "${HOST_ENTRY_OIO}" >> /etc/hosts

HOST_ENTRY_WEBAPP='192.168.100.20   webapp.open.io'
grep "${HOST_ENTRY_WEBAPP}" /etc/hosts || echo "${HOST_ENTRY_WEBAPP}" >> /etc/hosts

# /usr/local/bin/kubectl completion bash > /etc/bash_completion.d/kubectl
# /usr/local/bin/kubectl get pod --all-namespaces
# /usr/local/bin/kubectl create -f /vagrant/kubernetes/s3-secret.yaml
# /usr/local/bin/kubectl create -f /vagrant/kubernetes/provisioner.yaml
# /usr/local/bin/kubectl create -f /vagrant/kubernetes/attacher.yaml
# /usr/local/bin/kubectl create -f /vagrant/kubernetes/csi-s3.yaml
