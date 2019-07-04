FROM centos:7 as base

RUN yum install -y \
    curl-devel epel-release \
    git-core chrpath libtool make which \
    libX11-devel libXdamage-devel libXext-devel libXt-devel libXi-devel \
    libxcb-devel xorg-x11-xtrans-devel libXcursor-devel libXft-devel \
    libXinerama-devel libXrandr-devel libXrender-devel libxkbcommon-x11 \
    mesa-libGL-devel mesa-libGLU-devel mesa-dri-drivers

RUN yum install -y centos-release-scl \
    && yum install -y devtoolset-6-gcc devtoolset-6-gcc-c++ \
    devtoolset-6-gcc-gfortran

RUN yum clean all

RUN useradd -c paraview -d /home/paraview -M paraview \
    && mkdir /home/paraview \
    && chown paraview:paraview /home/paraview
USER paraview

ENV MAKE=/usr/bin/make

COPY scripts/install_cmake.sh /home/paraview/install_cmake.sh
RUN scl enable devtoolset-6 -- sh /home/paraview/install_cmake.sh

COPY scripts/install_ninja.sh /home/paraview/install_ninja.sh
RUN scl enable devtoolset-6 -- sh /home/paraview/install_ninja.sh

ENV PATH="/home/paraview/cmake/bin:${PATH}"

COPY scripts/download_qt.sh /home/paraview/download_qt.sh
COPY scripts/extract-qt-installer /home/paraview/extract-qt-installer
RUN sh /home/paraview/download_qt.sh
ENV Qt5_DIR="/home/paraview/qt/5.12.1/gcc_64/lib/cmake/Qt5"


FROM base as builder

COPY scripts/build_paraview.sh /home/paraview/build_paraview.sh
RUN scl enable devtoolset-6 -- sh /home/paraview/build_paraview.sh

FROM base as default
COPY --from=builder /home/paraview/build/install /home/paraview/build/install
ENV CMAKE_PREFIX_PATH=/home/paraview/build/install

FROM default as package
COPY --from=builder /home/paraview/package /home/paraview/package


FROM default

