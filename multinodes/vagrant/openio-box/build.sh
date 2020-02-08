#!/bin/bash

set -eu -o pipefail

CURRENT_DIR="$(cd "$(dirname "$0")" && pwd -P)"
BOX_FILE="${CURRENT_DIR}"/openio.box

[ ! -f "${BOX_FILE}" ] || rm -f "${BOX_FILE}"

vagrant destroy -f

vagrant up

vagrant package --output "${BOX_FILE}"

vagrant box add --force openio-box "${BOX_FILE}" 

vagrant destroy -f
