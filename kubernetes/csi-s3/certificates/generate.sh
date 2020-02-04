#!/bin/bash

set -eux -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

## Generate certificates in current dir

command -v >/dev/null || (
    echo "ERROR: mkcert is required"
    exit 1
)

mkcert -key-file "${CURRENT_DIR}/cert-key.pem" -cert-file "${CURRENT_DIR}/cert.pem" \
    open.io s3.open.io 172.17.0.1 10.0.2.2 10.0.2.15 127.0.0.1 "*.openio"

cp "$(mkcert -CAROOT)/rootCA.pem" "${CURRENT_DIR}/rootCA.pem"
