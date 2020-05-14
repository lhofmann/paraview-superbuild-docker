#!/bin/bash

cmake \
    --no-warn-unused-cli \
    -Dsuperbuild_download_location="/home/paraview/downloads" \
    -Dparaview_FROM_GIT=ON \
    -Dparaview_GIT_TAG="$paraview_version" \
    -Dparaview_FROM_SOURCE_DIR=OFF \
    -DSUPERBUILD_PROJECT_PARALLELISM=8 \
    -DFULL_BUILD=ON \
    -DPYTHON_VERSION=3 \
    -DENABLE_python2=OFF \
    -DENABLE_python3=ON \
    -DBUILD_TESTING=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DDIY_SKIP_SVN=ON \
    -DENABLE_boost=ON \
    -DENABLE_ffmpeg=ON \
    -DENABLE_fontconfig=ON \
    -DENABLE_glu=ON \
    -DENABLE_h5py=ON \
    -DENABLE_matplotlib=ON \
    -DENABLE_mpi=ON \
    -DENABLE_netcdf=ON \
    -DENABLE_numpy=ON \
    -DENABLE_paraview=ON \
    -DENABLE_python=ON \
    -DENABLE_qt5=ON \
    -DENABLE_scipy=ON \
    -DENABLE_tbb=ON \
    -DENABLE_zfp=ON \
    -DPARAVIEW_DEFAULT_SYSTEM_GL=ON \
    -DUSE_NONFREE_COMPONENTS=ON \
    -DUSE_SYSTEM_qt5=ON \
    -DENABLE_acusolve=ON \
    -DENABLE_adios2=ON \
    -DENABLE_boxlib=ON \
    -DENABLE_cosmotools=ON \
    -DENABLE_las=ON \
    -DENABLE_mesa=ON \
    -DENABLE_mili=ON \
    -DENABLE_nvidiaindex=ON \
    -DENABLE_ospray=ON \
    -DENABLE_paraviewweb=ON \
    -DENABLE_silo=ON \
    -DENABLE_visitbridge=ON \
    -DENABLE_vistrails=ON \
    -DENABLE_vortexfinder2=ON \
    -DENABLE_vrpn=ON \
    -DENABLE_vtkm=ON \
    -DENABLE_xdmf3=ON \
    -Dvtkm_SOURCE_SELECTION="for-git" \
    -DCMAKE_INSTALL_PREFIX="/home/paraview/package" \
    "-GUnix Makefiles" \
    "/home/paraview/paraview-superbuild" 
