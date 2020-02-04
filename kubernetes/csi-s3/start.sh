#!/bin/bash

set -euo pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"


# Start OiO
cd "${CURRENT_DIR}/oio"

docker-compose up -d

# Load Certificates in Kubernetes
kubectl create secret generic oio-certs --from-file=/certificates

cd "${CURRENT_DIR}/manifests"
