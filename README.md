# ParaView Superbuild Docker Image

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Build Status](https://travis-ci.org/lhofmann/paraview-superbuild-docker.svg?branch=master)](https://travis-ci.org/lhofmann/paraview-superbuild-docker)

Building [ParaView](https://www.paraview.org/) plugins, that are compatible with the ParaView binary distribution, currently requires to reproduce the [ParaView superbuild](https://gitlab.kitware.com/paraview/paraview-superbuild). 
This docker image contains ParaView superbuild binaries as well as their development headers, which allows external plugins to be built. Any plugin built in this environment can be distributed and used within the ParaView binary distribution.

Currently, supported are the following versions:

* [ParaView-5.6.0-MPI-Linux-64bit](https://www.paraview.org/files/v5.6/ParaView-5.6.0-MPI-Linux-64bit.tar.gz) (Qt5 GUI)
* [ParaView-5.6.0-osmesa-MPI-Linux-64bit](https://www.paraview.org/files/v5.6/ParaView-5.6.0-osmesa-MPI-Linux-64bit.tar.gz) (no GUI, software rendering)
* [ParaView-5.6.0-egl-MPI-Linux-64bit](https://github.com/lhofmann/paraview-superbuild-docker/releases/download/5.6.0/ParaView-5.6.0-egl-MPI-Linux-64bit.tar.gz) (no GUI, hardware rendering)


This docker images are partially based on the Dockerfiles found on the [ParaView mailing list](https://public.kitware.com/pipermail/paraview/2017-April/039841.html) and in the [ParaView superbuild repository](https://gitlab.kitware.com/paraview/paraview-superbuild/tree/master/Scripts/docker/el6). The CMake configuration is taken from the [ParaView CDash](https://open.cdash.org/index.php?project=ParaView).

## Usage

[docker](https://www.docker.com/) running on a Linux (or compatible) environment is required.

Prebuilt docker images can be found on [Docker Hub](https://hub.docker.com/r/lhofmann/paraview-superbuild). If you want to build your own docker images, see the instructions below (building takes about three hours on a desktop machine).

Available images are

* `lhofmann/paraview-superbuild:5.6.0`
* `lhofmann/paraview-superbuild:5.6.0-osmesa`
* `lhofmann/paraview-superbuild:5.6.0-egl`

The images have preset `PATH`, `Qt5_DIR` and `CMAKE_PREFIX_PATH` environment variables. In order to select gcc from the SCL, commands that run CMake need to be executed using `scl enable devtoolset-4`.

### Using a shell in a container

Create a directory `shared` and mount it into the docker container:
```bash
mkdir shared
docker run -it \
  --volume="$(pwd)/shared:/mnt/shared:rw" \
  lhofmann/paraview-superbuild:5.6.0 \
  /usr/bin/scl enable devtoolset-4 -- /bin/bash --login
```
The same can be achieved by cloning this repository and executing `run.sh`. This will create the subdirectory `paraview-superbuild-docker/shared` and mounts it as above.
```bash
git clone https://github.com/lhofmann/paraview-superbuild-docker.git
./paraview-superbuild-docker/run.sh
```
After executing one of the above commands, simply use cmake to build your plugin (in the `shared` directory). For example, to build the plugin `shared/example`:
```bash
cd /mnt/shared
mkdir build && cd build
cmake ../example
cmake --build .
```

### Using a detached container

Start a detached container with name `build`
```bash
docker run -itd --name build \
  --volume="$(pwd)/shared:/mnt/shared:rw" \
  lhofmann/paraview-superbuild:5.6.0  
```
Run CMake and build
```bash
docker exec build /usr/bin/scl enable devtoolset-4 -- cmake -B/mnt/shared/build -H/mnt/shared/example
docker exec build cmake --build /mnt/shared/build
```

This is also demonstrated in the [Travis build](https://travis-ci.org/lhofmann/paraview-superbuild-docker), which builds a plugin using the docker image and executes it using the ParaView binary distribution. See also [.travis.yml](.travis.yml).

## Building the docker images

This is a multi-stage Dockerfile with four stages: `base`, `builder`, `default` and `package`.

* `base` contains the dependencies required for building the ParaView superbuild, including recent versions of cmake, ninja and the Qt5 binary distribution.
* `builder` contains the fully built ParaView superbuild in `/home/paraview/build`, including all build artifacts.
* `default` contains the `base` image and the directory `/home/paraview/build/install`, which contains the ParaView superbuild binaries.
* `package` contains the `default` image and package-ready ParaView binaries in `/home/paraview/package`. These binaries can be distributed and approximately resemble those found in the ParaView binary distribution.

The docker images [lhofmann/paraview-superbuild](https://hub.docker.com/r/lhofmann/paraview-superbuild) contain the `default` stage. To replicate these images, run
```bash
git clone https://github.com/lhofmann/paraview-superbuild-docker.git
./paraview-superbuild-docker/build.sh
```
In order to keep the intermediate stages, run `./paraview-superbuild-docker/build.sh all`.

The script will create docker images with tag `paraview-superbuild:5.6.0` for the `default` stage and `paraview-superbuild:5.6.0-base`, `paraview-superbuild:5.6.0-builder`, `paraview-superbuild:5.6.0-package` for the other stages.

The full usage of the build script, which can also build the `osmesa` and `egl` variants, is
```bash
./paraview-superbuild-docker/build.sh [osmesa|egl] [all]
```
