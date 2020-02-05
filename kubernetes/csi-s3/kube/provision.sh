#!/bin/bash
set -eux -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

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

## Deploy CSI-S3 Manifests

# Start by storing self signed certificates from OpenIO as a kube secret
NAMESPACE_NAME="csi-s3"
kubectl create namespace "${NAMESPACE_NAME}"
kubectl create secret --namespace="${NAMESPACE_NAME}" generic oio-certs \
    --from-file="${CURRENT_DIR}/../certificates/cert.pem" \
    --from-file="${CURRENT_DIR}/../certificates/rootCA.pem"

kubectl apply -f "${CURRENT_DIR}/manifests/csi-s3"
