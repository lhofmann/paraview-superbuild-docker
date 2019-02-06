#!/bin/bash

set -e

BASE_DIR=$(dirname $(readlink -f ${BASH_SOURCE}))

if [ "${1:-}" = "all" ]; then
    docker build --target base --network=host --rm -t paraview-superbuild:5.6.0-base "${BASE_DIR}"
    docker build --target builder --network=host --rm -t paraview-superbuild:5.6.0-builder "${BASE_DIR}"
    docker build --target package --network=host --rm -t paraview-superbuild:5.6.0-package "${BASE_DIR}"
fi

docker build --network=host --rm -t paraview-superbuild:5.6.0 "${BASE_DIR}"
