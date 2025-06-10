#!/bin/bash

# vim: tabstop=4 shiftwidth=4 softtabstop=4
# -*- sh-basic-offset: 4 -*-

set -exuo pipefail

SRC=/src
QT_BRANCH_MAJOR="6.9"
QT_BRANCH_MINOR="1"
DEBIAN_VERSION=$(lsb_release -cs)
MAKE_CORES="$(expr $(nproc))"
BUILD_TARGET_PI=/build/qtpi-build

mkdir -p "$BUILD_TARGET_PI"

/usr/games/cowsay -f tux "Building QT version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."

function build_qtpi () {
    local SRC_DIR="$SRC/qt6"

    pushd "$BUILD_TARGET_PI"

    "$SRC_DIR"/configure -qpa eglfs \
            -confirm-license \
            -release \
            -qt-host-path /build/qt-host \
            -device-option CROSS_COMPILE=aarch64-linux-gnu- \
            -device linux-rasp-pi4-aarch64 \
            -eglfs \
            -extprefix /build/qt-raspi \
            -prefix /usr/local/qt6 \
            -pkg-config \
            -qt-pcre \
            -no-pch \
            -evdev \
            -system-freetype \
            -fontconfig \
            -glib \
            -make libs \
            -no-cups \
            -no-gtk \
            -no-use-gold-linker \
            -nomake examples \
            -nomake tests \
            -opensource \
            -skip qttools \
            -skip qtdoc \
            -skip qttranslations \
            -skip qtwebchannel \
            -skip qtwebengine \
            -skip qtwebview \
            -skip qtsensors \
            -skip qtvirtualkeyboard \
            -skip qtwebchannel \
            -skip qtspeech \
            -skip qtsql \
            -skip qtdbus \
            -skip qtxml \
            -skip qtjpeg \
            -skip qtlanguageserver \
            -skip qtwebsockets \
            -skip qthttpserver \
            -skip qtserialport \
            -skip qtpositioning \
            -skip qtlocation \
            -skip qtlottie \
            -skip qtmqtt \
            -skip qtremoteobjects \
            -skip qtserialbus \
            -skip qtsvg \
            -skip qtwayland \
            -skip qtcoap \
            -skip qt5compat \
            -skip qtconnectivity \
            -skip qtrpc=OFF \
            -skip qtimageformats \
            -skip qtopcua \
            -skip qtnetworkauth \
            -skip qtactiveqt \
            -skip qtgrpc \
            -skip qtscxml \
            -sysroot /sysroot \
            -- -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
                -DQT_FEATURE_xcb=ON \
                -DFEATURE_xcb_xlib=ON \
                -DQT_FEATURE_xlib=ON


    /usr/games/cowsay -f tux "Making QT Pi version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."

    cmake --build . --parallel "$MAKE_CORES"

    /usr/games/cowsay -f tux "Installing QT Pi version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."
    cmake --install .
    popd

    pushd "$SRC_DIR"
    tar cfz "$BUILD_TARGET_PI/qt6-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION-$1.tar.gz" qt6pi
    popd

    pushd "$BUILD_TARGET_PI"
    sha256sum "qt6-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION-$1.tar.gz" > "qt6-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION-$1.tar.gz.sha256"
    popd
}

build_qtpi