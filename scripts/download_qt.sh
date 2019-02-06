#!/bin/sh

set -e

readonly url="https://download.qt.io/official_releases/qt/5.10/5.10.1/qt-opensource-linux-x64-5.10.1.run"

readonly qt_file="/home/paraview/qt.run"
readonly qt_dir="/home/paraview/qt"

curl -L "$url" --output "$qt_file"

export QT_CI_PACKAGES=qt.qt5.5101.gcc_64
/bin/bash /home/paraview/extract-qt-installer "$qt_file" "$qt_dir"

rm "$qt_file"
