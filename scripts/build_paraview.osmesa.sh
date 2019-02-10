#!/bin/bash

set -e

readonly paraview_version="v5.6.0"

cd /home/paraview
git clone --recursive --branch "$paraview_version" --depth 1 https://gitlab.kitware.com/paraview/paraview-superbuild.git

mkdir -p /home/paraview/build
cd /home/paraview/build

cmake \
    "--no-warn-unused-cli"  \
    "-DCTEST_USE_LAUNCHERS:BOOL=1"  \
    "-DENABLE_vistrails:BOOL=ON"  \
    "-DENABLE_vrpn:BOOL=ON"  \
    "-DCMAKE_BUILD_TYPE:STRING=Release"  \
    "-DENABLE_netcdf:BOOL=ON"  \
    "-DENABLE_paraviewgettingstartedguide:BOOL=ON"  \
    "-DENABLE_visitbridge:BOOL=ON"  \
    "-DENABLE_mesa:BOOL=OFF"  \
    "-DENABLE_ffmpeg:BOOL=ON"  \
    "-DPARAVIEW_DEFAULT_SYSTEM_GL:BOOL=ON"  \
    "-DENABLE_qt5:BOOL=OFF"  \
    "-DENABLE_mpi:BOOL=ON"  \
    "-DENABLE_paraviewtutorialdata:BOOL=ON"  \
    "-DENABLE_paraview:BOOL=ON"  \
    "-DENABLE_xdmf3:BOOL=ON"  \
    "-DENABLE_h5py:BOOL=ON"  \
    "-DBUILD_SHARED_LIBS:BOOL=ON"  \
    "-Dvtkm_SOURCE_SELECTION:STRING=for-git"  \
    "-DENABLE_paraviewtutorial:BOOL=ON"  \
    "-DENABLE_vtkm:BOOL=OFF"  \
    "-DENABLE_numpy:BOOL=ON"  \
    "-DENABLE_paraviewusersguide:BOOL=ON"  \
    "-DENABLE_cosmotools:BOOL=ON"  \
    "-DENABLE_osmesa:BOOL=ON"  \
    "-Dsuperbuild_download_location:PATH=/home/paraview/downloads" \
    "-DENABLE_glu:BOOL=ON"  \
    "-DENABLE_tbb:BOOL=ON"  \
    "-DENABLE_boxlib:BOOL=ON"  \
    "-DENABLE_paraviewweb:BOOL=ON"  \
    "-DENABLE_silo:BOOL=OFF"  \
    "-DENABLE_boost:BOOL=ON"  \
    "-DENABLE_vortexfinder2:BOOL=OFF"  \
    "-DENABLE_python:BOOL=ON"  \
    "-DUSE_NONFREE_COMPONENTS:BOOL=ON"  \
    "-DENABLE_matplotlib:BOOL=ON"  \
    "-DENABLE_las:BOOL=ON"  \
    "-DBUILD_TESTING:BOOL=ON"  \
    "-DENABLE_scipy:BOOL=ON"  \
    "-DENABLE_ospray:BOOL=ON"  \
    "-DENABLE_acusolve:BOOL=ON"  \
    "-DENABLE_fontconfig:BOOL=ON"  \
    "-Dparaview_FROM_GIT:BOOL=ON" \
    "-Dparaview_GIT_TAG:STRING=$paraview_version" \
    "-Dparaview_FROM_SOURCE_DIR:BOOL=OFF" \
    "-DCTEST_USE_LAUNCHERS:BOOL=TRUE"  \
    "-DCMAKE_INSTALL_PREFIX=/home/paraview/package" \
    "-GUnix Makefiles"  \
    "/home/paraview/paraview-superbuild" 

make -j1
make install
