#!/bin/bash
#
# Usage: build.sh [osmesa|egl] [all]
#

set -e

readonly paraview_version="5.8.0"

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

build_args="--build-arg IMAGE_NAME=${base_image} --build-arg QT_LOGIN=${QT_LOGIN} --build-arg QT_PASSWORD=${QT_PASSWORD}"

if [ ${file_suffix} = ".qt" ]; then
    if [ -z "${QT_LOGIN}" ] || [ -z "${QT_PASSWORD}"]; then
	echo "ERROR: Downloading Qt requires a qt.io account set as environment variables QT_LOGIN/QT_PASSWORD."
	exit 1
    fi

    docker build --target intermediate --network=host --rm  -t ${tag}-intermediate -f "${dockerfile}" \
        ${build_args} "${BASE_DIR}"
fi

docker build --target base --network=host --rm  -t ${tag}-base -f "${dockerfile}" \
    ${build_args} "${BASE_DIR}"

docker build --target builder --network=host --rm -t ${tag}-builder -f "${dockerfile}" \
    ${build_args} "${BASE_DIR}"

docker build --target package --network=host --rm -t ${tag}-package -f "${dockerfile}"  \
    ${build_args} "${BASE_DIR}"

docker build --network=host --rm -t ${tag} -f "${dockerfile}"  \
    ${build_args} "${BASE_DIR}"


# create package
docker run -itd --name paraview-package ${tag}-package
docker exec paraview-package bash -c "mv /home/paraview/package /home/paraview/ParaView-${paraview_version}${tag_suffix}-MPI-Linux-Python3.7-64bit"
docker exec paraview-package bash -c  "cd /home/paraview && tar czf ParaView-${paraview_version}${tag_suffix}-MPI-Linux-Python3.7-64bit.tar.gz ParaView-${paraview_version}${tag_suffix}-MPI-Linux-Python3.7-64bit/"
docker cp paraview-package:/home/paraview/ParaView-${paraview_version}${tag_suffix}-MPI-Linux-Python3.7-64bit.tar.gz .
docker stop paraview-package
docker rm paraview-package

