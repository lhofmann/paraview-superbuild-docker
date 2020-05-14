# ParaView Superbuild Docker Image

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Build Status](https://travis-ci.org/lhofmann/paraview-superbuild-docker.svg?branch=master)](https://travis-ci.org/lhofmann/paraview-superbuild-docker)

Building [ParaView](https://www.paraview.org/) plugins, that are compatible with the ParaView binary distribution, currently requires to reproduce the [ParaView superbuild](https://gitlab.kitware.com/paraview/paraview-superbuild). 
This docker image contains ParaView superbuild binaries as well as their development headers, which allows external plugins to be built. Any plugin built in this environment can be distributed and used within the ParaView binary distribution.

Three variants for each version are provided: Qt5 GUI (no suffix), off-screen software rendering (OSMesa, suffix *-osmesa*) and hardware off-screen rendering (EGL, suffix *-egl*). The EGL variant requires libglvnd.

| ParaView Release | Docker Image |
|--|--|
| [ParaView-5.7.0-MPI-Linux-Python3.7-64bit](https://www.paraview.org/files/v5.7/ParaView-5.7.0-MPI-Linux-Python3.7-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0 |
| [ParaView-5.7.0-osmesa-MPI-Linux-Python3.7-64bit](https://www.paraview.org/files/v5.7/ParaView-5.7.0-osmesa-MPI-Linux-Python3.7-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0-osmesa |
| [ParaView-5.7.0-egl-MPI-Linux-Python3.7-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.7.0-RC2/ParaView-5.7.0-egl-MPI-Linux-Python3.7-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0-egl |
| [ParaView-5.6.2-MPI-Linux-64bit](https://www.paraview.org/files/v5.6/ParaView-5.6.2-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.2 |
| [ParaView-5.6.2-osmesa-MPI-Linux-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.6.2/ParaView-5.6.2-osmesa-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.2-osmesa |
| [ParaView-5.6.2-egl-MPI-Linux-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.6.2/ParaView-5.6.2-egl-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.2-egl |

This docker images are partially based on the Dockerfiles found on the [ParaView mailing list](https://public.kitware.com/pipermail/paraview/2017-April/039841.html) and in the [ParaView superbuild repository](https://gitlab.kitware.com/paraview/paraview-superbuild/tree/master/Scripts/docker/el6). The CMake configuration is taken from the [ParaView CDash](https://open.cdash.org/index.php?project=ParaView).

## Usage

[docker](https://www.docker.com/) running in a Linux (or compatible) environment is required. All instructions assume, that your user is a member of the `docker` group.

Prebuilt docker images can be found on [Docker Hub](https://hub.docker.com/r/lhofmann/paraview-superbuild). If you want to build your own docker images, see the instructions below (building takes about three hours on a desktop machine).

The images have preset `PATH`, `Qt5_DIR` and `CMAKE_PREFIX_PATH` environment variables. In order to select gcc from the SCL, commands that run CMake need to be executed using `scl enable devtoolset-8` (version 5.7.0 uses `devltoolset-6` and version 5.6.0 uses `devtoolset-4`; you may also install your own toolset, see below).

Start a detached container with name `build` and directory `./shared/` mounted to `/mnt/shared`:
```bash
docker run -itd                              \
  --name build                               \
  --user "$(id -u ${USER}):$(id -g ${USER})" \
  --volume="$(pwd)/shared:/mnt/shared:ro"    \
  lhofmann/paraview-superbuild:5.8.0
```
Run CMake and build in `/tmp/build`:
```bash
docker exec build /usr/bin/scl enable devtoolset-8 -- cmake -B/tmp/build -H/mnt/shared/example
docker exec build cmake --build /tmp/build
```
The build artifacts are now in `/tmp/build` within the docker container. You may copy the required files to the host:
```bash
docker cp build:/tmp/build/libExamplePlugin.so .
```

This is also demonstrated in the [Travis build](https://travis-ci.org/lhofmann/paraview-superbuild-docker), which builds a plugin using the docker image and executes it using the ParaView binary distribution. See also [.travis.yml](.travis.yml).

Full working examples can be found in [examples/](examples).

## Extending the docker images

The docker images run as non-root user `paraview`. If you need additional dependencies for your builds, create a derived docker image:
```dockerfile
ARG paraview_version="5.8.0"
FROM lhofmann/paraview-superbuild:${paraview_version}
USER root

# install additional dependencies
# e.g.:
# RUN yum install -y ...

USER paraview
```


## Building the docker images

This is a multi-stage Dockerfile with four stages: `base`, `builder`, `default` and `package`.

* `base` contains the dependencies required for building the ParaView superbuild, including recent versions of cmake and the Qt5 binary distribution.
* `builder` contains the fully built ParaView superbuild in `/home/paraview/build`, including all build artifacts.
* `default` contains the `base` image and the directory `/home/paraview/build/install`, which contains the ParaView superbuild binaries.
* `package` contains the `default` image and package-ready ParaView binaries in `/home/paraview/package`. These binaries can be distributed and approximately resemble those found in the ParaView binary distribution.

The docker images [lhofmann/paraview-superbuild](https://hub.docker.com/r/lhofmann/paraview-superbuild) contain the `default` stage. To replicate these images, run
```bash
git clone https://github.com/lhofmann/paraview-superbuild-docker.git
./paraview-superbuild-docker/build.sh [osmesa|egl]
```

The script will create docker images with tag `$USER/paraview-superbuild:5.78.0` for the `default` stage and `$USER/paraview-superbuild:5.8.0-base`, `$USER/paraview-superbuild:5.8.0-builder`, `$USER/paraview-superbuild:5.8.0-package` for the other stages.


## Changelog

### 5.8.0

* switched to `devtoolset-8` (gcc 8)
* Qt now requires a qt.io account for downloading binaries
    * building paraview using Qt requires the account set as environment variables `QT_LOGIN` and `QT_PASSWORD`
    * some care is taken, that the login is not leaked into the final docker image, by using another intermediate stage (tagged -intermediate)
* cleaned up CMake configuration according to https://gitlab.kitware.com/paraview/paraview-plugin-builder
* `build.sh` also creates a binary .tar.gz package

### 5.7.0

* changed build path to `/home/paraview/buildbuildbuildbuildbuildbuildbuildbuildbuildbuildbuildbuildbuildbuild` as workaround for [issue #123](https://gitlab.kitware.com/paraview/paraview-superbuild/issues/123)
* additionally define `TBB_ROOT` (fixes CMake sometimes failing)
* updated extract-qt-installer to revision 2fa3063 of github.com/benlau/qtci
* removed symlink to ospray include directory, as it is no longer needed

### 5.6.2

* add symlink at `build/install/include/paraview-5.6/ospray` to `build/install/include/ospray`

### 5.7.0-RC1

* use `devtoolset-6` (gcc 6) instead of `devtoolset-4`
* update to Qt 5.12.1
* update to CMake 3.13.4

## Old Releases

| ParaView Release | Docker Image |
|--|--|
| [ParaView-5.7.0-RC2-MPI-Linux-Python3.7-64bit](https://www.paraview.org/files/v5.7/ParaView-5.7.0-RC2-MPI-Linux-Python3.7-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0-RC2 |
| [ParaView-5.7.0-RC2-osmesa-MPI-Linux-Python3.7-64bit](https://www.paraview.org/files/v5.7/ParaView-5.7.0-RC2-osmesa-MPI-Linux-Python3.7-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0-RC2-osmesa |
| [ParaView-5.7.0-RC2-egl-MPI-Linux-Python3.7-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.7.0-RC2/ParaView-5.7.0-RC2-egl-MPI-Linux-Python3.7-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0-RC2-egl |
| [ParaView-5.7.0-RC1-MPI-Linux-64bit](https://www.paraview.org/files/v5.6/ParaView-5.7.0-RC1-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0-RC1 |
| [ParaView-5.7.0-RC1-osmesa-MPI-Linux-64bit](https://www.paraview.org/files/v5.6/ParaView-5.7.0-RC1-osmesa-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0-RC1-osmesa |
| [ParaView-5.7.0-RC1-egl-MPI-Linux-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.7.0-RC1/ParaView-5.7.0-RC1-egl-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.7.0-RC1-egl |
| [ParaView-5.6.0-295-g74fd1a6d5a-MPI-Linux-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.6.0-295-g74fd1a6d5a/ParaView-5.6.0-295-g74fd1a6d5a-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.0-295-g74fd1a6d5a |
| [ParaView-5.6.0-295-g74fd1a6d5a-osmesa-MPI-Linux-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.6.0-295-g74fd1a6d5a/ParaView-5.6.0-295-g74fd1a6d5a-osmesa-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.0-295-g74fd1a6d5a-osmesa |
| [ParaView-5.6.0-295-g74fd1a6d5a-egl-MPI-Linux-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.6.0-295-g74fd1a6d5a/ParaView-5.6.0-295-g74fd1a6d5a-egl-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.0-295-g74fd1a6d5a-egl |
| [ParaView-5.6.0-MPI-Linux-64bit](https://www.paraview.org/files/v5.6/ParaView-5.6.0-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.0 |
| [ParaView-5.6.0-osmesa-MPI-Linux-64bit](https://www.paraview.org/files/v5.6/ParaView-5.6.0-osmesa-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.0-osmesa |
| [ParaView-5.6.0-egl-MPI-Linux-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.6.0/ParaView-5.6.0-egl-MPI-Linux-64bit.tar.gz) | lhofmann/paraview-superbuild:5.6.0-egl |
