#!/bin/bash

set -eux -o pipefail

CURRENT_DIR="$(cd "$(dirname "${0}")" && pwd -P)"

## Check mkcert - https://github.com/FiloSottile/mkcert is installed
command -v mkcert || (
  echo "ERROR: command mkcert (https://github.com/FiloSottile/mkcert) is required and cannot be found. Aborting."
  exit 1
)

# Generate certificate with SANs
mkcert -key-file "${CURRENT_DIR}/cert-key.pem" -cert-file "${CURRENT_DIR}/cert.pem" external.data.openio internal.data.openio "*.data.openio"

# Get the CA file, required for full trust from cacert trust stores
cp "$(mkcert -CAROOT)/rootCA.pem" "${CURRENT_DIR}/rootCA.pem"
