#!/bin/bash
#
# Usage: build.sh [osmesa|egl] [all]
#

set -e

readonly paraview_version="5.7.0-RC1"

BASE_DIR=$(dirname $(readlink -f ${BASH_SOURCE}))

tag_suffix=""
file_suffix=".qt"

if [ "${1:-}" = "osmesa" ]; then
    tag_suffix="-osmesa"
    file_suffix=".osmesa"
elif [ "${1:-}" = "egl" ]; then
    tag_suffix="-egl"
    file_suffix=".egl"
fi

readonly base_image="${USER}/paraview-superbuild:${paraview_version}-common"

docker build --network=host --rm -t "${base_image}" -f "${BASE_DIR}/Dockerfile.base" \
    --build-arg paraview_version=v${paraview_version} \
    --build-arg superbuild_version=v${paraview_version} \
    "${BASE_DIR}"

readonly tag="${USER}/paraview-superbuild:${paraview_version}${tag_suffix}"
readonly dockerfile="${BASE_DIR}/Dockerfile${file_suffix}"

docker build --target base --network=host --rm  -t ${tag}-base -f "${dockerfile}" \
    --build-arg IMAGE_NAME=${base_image} \
    "${BASE_DIR}"

docker build --target builder --network=host --rm -t ${tag}-builder -f "${dockerfile}" \
    --build-arg IMAGE_NAME=${base_image} \
    "${BASE_DIR}"

docker build --target package --network=host --rm -t ${tag}-package -f "${dockerfile}"  \
    --build-arg IMAGE_NAME=${base_image} \
    "${BASE_DIR}"

docker build --network=host --rm -t ${tag} -f "${dockerfile}"  \
    --build-arg IMAGE_NAME=${base_image} \
    "${BASE_DIR}"
