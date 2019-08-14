#!/bin/bash
#
# Usage: build_paraview-vtk-template_ParaView5.6.sh [ -egl | -osmesa ]
#

set -e

readonly paraview_version="5.6.0$1"
readonly image=lhofmann/paraview-superbuild:${paraview_version}
readonly container=build-${paraview_version}
readonly cwd="$(dirname "$(readlink -f "$0")")"

docker run -itd \
  --user "$(id -u ${USER}):$(id -g ${USER})" \
  --name ${container} \
  --volume="${cwd}/paraview-vtk-template:/mnt/source:rw" \
  ${image}

docker exec ${container} /usr/bin/scl enable devtoolset-4 -- cmake \
  -B/tmp/build \
  -H/mnt/source \
  -DCMAKE_INSTALL_PREFIX=/tmp/install/ParaView-${paraview_version}-MPI-Linux-64bit
docker exec ${container} cmake --build /tmp/build --target install

docker cp ${container}:/tmp/install/. .
docker stop ${container}
docker rm ${container}
