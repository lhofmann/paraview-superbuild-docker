FROM centos:7 as base

RUN yum install -y \
    curl-devel epel-release \
    git-core chrpath libtool make which \
    libX11-devel libXdamage-devel libXext-devel libXt-devel libXi-devel \
    libxcb-devel xorg-x11-xtrans-devel libXcursor-devel libXft-devel \
    libXinerama-devel libXrandr-devel libXrender-devel \
    mesa-libGL-devel mesa-libGLU-devel mesa-dri-drivers

RUN yum install -y centos-release-scl \
    && yum install -y devtoolset-4-gcc devtoolset-4-gcc-c++ \
    devtoolset-4-gcc-gfortran

RUN yum clean all

RUN useradd -c paraview -d /home/paraview -M paraview \
    && mkdir /home/paraview \
    && chown paraview:paraview /home/paraview
USER paraview

ENV MAKE=/usr/bin/make

COPY scripts /home/paraview/

RUN scl enable devtoolset-4 -- sh /home/paraview/install_cmake.sh
RUN scl enable devtoolset-4 -- sh /home/paraview/install_ninja.sh

ENV PATH="/home/paraview/cmake/bin:${PATH}"

RUN sh /home/paraview/download_qt.sh
ENV Qt5_DIR="/home/paraview/qt/5.10.1/gcc_64/lib/cmake/Qt5"


FROM base as builder

RUN scl enable devtoolset-4 -- sh /home/paraview/build_paraview.sh

FROM base as default
COPY --from=builder /home/paraview/build/install /home/paraview/build/install
ENV CMAKE_PREFIX_PATH=/home/paraview/build/install

FROM default as package
COPY --from=builder /home/paraview/package /home/paraview/package


FROM default

