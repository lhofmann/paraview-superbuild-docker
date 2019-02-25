#!/bin/bash
#
# Usage: build.sh [osmesa|egl] [all]
#

set -e

readonly paraview_version="5.6.0-295-g74fd1a6d5a"

BASE_DIR=$(dirname $(readlink -f ${BASH_SOURCE}))

tag_suffix=""
file_suffix=""

if [ "${1:-}" = "osmesa" ]; then
    tag_suffix="-osmesa"
    file_suffix=".osmesa"
elif [ "${1:-}" = "egl" ]; then
    tag_suffix="-egl"
    file_suffix=".egl"
fi

readonly tag="paraview-superbuild:${paraview_version}${tag_suffix}"
readonly dockerfile="${BASE_DIR}/Dockerfile${file_suffix}"

if [[ "${1:-}" = "all" || "${2:-}" = "all" ]]; then
    docker build --target base --network=host --rm \
        -t "${tag}-base" -f "${dockerfile}" "${BASE_DIR}"
    docker build --target builder --network=host --rm \
        -t "${tag}-builder" -f "${dockerfile}" "${BASE_DIR}"
    docker build --target package --network=host --rm \
        -t "${tag}-package" -f "${dockerfile}" "${BASE_DIR}"
fi

docker build --target package --network=host --rm \
    -t "${tag}" -f "${dockerfile}" "${BASE_DIR}"
