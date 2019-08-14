#!/bin/bash
#
# Usage: build_ttk.sh [ -egl | -osmesa ]
#
# This example pulls the ttk source code and builds it using the superbuild docker image.
# Currently, none of ttk's optional dependencies are installed.
#

readonly paraview_version="5.6.0$1"
readonly container=build-ttk-${paraview_version}
readonly cwd="$(dirname "$(readlink -f "$0")")"

git clone --recursive --branch "v0.9.7" --depth 1 https://github.com/topology-tool-kit/ttk.git

docker run -itd \
  --user "$(id -u ${USER}):$(id -g ${USER})" \
  --name ${container} \
  --volume="${cwd}/ttk:/mnt/source:ro" \
  lhofmann/paraview-superbuild:${paraview_version}

docker exec ${container} /usr/bin/scl enable devtoolset-4 -- cmake \
    -B/tmp/superbuild \
    -H/mnt/source \
    -DTTK_BUILD_VTK_WRAPPERS=OFF \
    -DTTK_BUILD_STANDALONE_APPS=OFF \
    -DTTK_BUILD_PARAVIEW_PLUGINS=ON \
    -DTTK_ENABLE_CPU_OPTIMIZATION=OFF \
    -DTTK_ENABLE_64BIT_IDS=ON \
    -DCMAKE_INSTALL_PREFIX=/tmp/install-ttk \
    -DTTK_INSTALL_PLUGIN_DIR=/tmp/install/ParaView-${paraview_version}-MPI-Linux-64bit/lib/plugins/

docker exec ${container} cmake --build /tmp/superbuild --target install -- -j4

docker cp ${container}:/tmp/install/. .
docker stop ${container}
docker rm ${container}
