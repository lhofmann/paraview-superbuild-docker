#!/bin/sh

set -e

readonly common_sb_url="https://gitlab.kitware.com/paraview/common-superbuild.git"
readonly commit="cb8df4df8ddc57b8afc6c2c1c85004217ce40f71"

readonly workdir="/home/paraview/qt-build"
readonly srcdir="$workdir/src"
readonly builddir="$workdir/build"

mkdir -p "$builddir"
git clone "${common_sb_url}" "$srcdir"
cd "$srcdir"
git checkout "$commit"

cd "$builddir"
cmake \
  -DSUPERBUILD_PROJECT_PARALLELISM=8 \
  -DENABLE_qt5:BOOL=ON \
  "-Dqt_install_location:PATH=/home/paraview/qt" \
  "-Dqt5_SOURCE_SELECTION:STRING=5.12" \
  "-Dqt5_ENABLE_SVG:BOOL=ON" \
  "$srcdir/standalone-qt"
make -j1

rm -rf "$workdir"
