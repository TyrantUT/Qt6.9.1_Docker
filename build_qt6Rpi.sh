#!/bin/bash

# vim: tabstop=4 shiftwidth=4 softtabstop=4
# -*- sh-basic-offset: 4 -*-

set -exuo pipefail

BUILD_TARGET=/build/qt6_host
SRC=/src
QT_BRANCH="6.4.0"
DEBIAN_VERSION=$(lsb_release -cs)
MAKE_CORES="$(expr $(nproc) + 2)"
BUILD_TARGET_PI=/build/qt6_rpi

mkdir -p "$BUILD_TARGET_PI"

/usr/games/cowsay -f tux "Building QT version $QT_BRANCH."

function build_qtpi () {

    local SRC_DIR="/src/qt6pi"

    mkdir -p "$SRC_DIR"

    pushd "$BUILD_TARGET_PI"

    "$SRC"/qt6/configure -qpa eglfs \
            -confirm-license \
            -release \
            -qt-host-path /opt/qt6 \
            -device-option CROSS_COMPILE=/src/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf- \
            -eglfs \
            -extprefix "$SRC_DIR/qt6pi" \
            -prefix /usr/local/qt5pi \
            -pkg-config \
            -qt-pcre \
            -no-pch \
            -evdev \
            -system-freetype \
            -fontconfig \
            -glib \
            -make libs \
            -no-compile-examples \
            -no-cups \
            -no-gtk \
            -no-use-gold-linker \
            -nomake examples \
            -nomake tests \
            -opensource \
            -skip qtwebengine \
            -skip qtandroidextras \
            -skip qtgamepad \
            -skip qtlocation \
            -skip qtlottie \
            -skip qtmacextras \
            -skip qtpurchasing \
            -skip qtscxml \
            -skip qtsensors \
            -skip qtserialbus \
            -skip qtserialport \
            -skip qtspeech \
            -skip qttools \
            -skip qttranslations \
            -skip qtvirtualkeyboard \
            -skip qtwayland \
            -skip qtwebview \
            -skip qtwinextras \
            -skip wayland \
            -sysroot /sysroot \
            -recheck -- -DCMAKE_TOOLCHAIN_FILE=/usr/local/bin//toolchain.cmake -DQT_FEATURE_xcb=ON -DFEATURE_xcb_xlib=ON -DQT_FEATURE_xlib=ON

    /usr/games/cowsay -f tux "Making QT Pi version $QT_BRANCH."
    cmake --build . --parallel "$MAKE_CORES"

    /usr/games/cowsay -f tux "Installing QT Pi version $QT_BRANCH."
    cmake --install .
    popd

    pushd "$SRC_DIR"
    tar cfz "$BUILD_TARGET_PI/qt5-$QT_BRANCH-$DEBIAN_VERSION-$1.tar.gz" qt6pi
    popd

    pushd "$BUILD_TARGET_PI"
    sha256sum "qt5-$QT_BRANCH-$DEBIAN_VERSION-$1.tar.gz" > "qt5-$QT_BRANCH-$DEBIAN_VERSION-$1.tar.gz.sha256"
    popd
}

build_qtpi