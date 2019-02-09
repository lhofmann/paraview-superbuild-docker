#!/bin/bash

BASE_DIR=$(dirname $(readlink -f ${BASH_SOURCE}))
mkdir -p ${BASE_DIR}/shared
chmod 6755 ${BASE_DIR}/shared

docker run -it \
  --volume="${BASE_DIR}/shared:/mnt/shared:rw" \
  --net=host \
  lhofmann/paraview-superbuild:5.6.0 \
  /usr/bin/scl enable devtoolset-4 -- /bin/bash --login

