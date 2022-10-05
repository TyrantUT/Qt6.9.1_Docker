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

mkdir -p "$BUILD_TARGET"
mkdir -p "$BUILD_TARGET_PI"
mkdir -p "$SRC"

/usr/games/cowsay -f tux "Building QT version $QT_BRANCH."

function fetch_rpi_firmware () {
    if [ ! -d "/src/opt" ]; then
        pushd /src

        # We do an `svn checkout` here as the entire git repo here is *huge*
        # and `git` doesn't  support partial checkouts well (yet)
        svn checkout -q https://github.com/raspberrypi/firmware/trunk/opt
        popd
    fi

    # We need to exclude all of these .h and android files to make QT build.
    # In the blog post referenced, this is done using `dpkg --purge libraspberrypi-dev`,
    # but since we're copying in the source, we're just going to exclude these from the rsync.
    # https://www.enricozini.org/blog/2020/qt5/build-qt5-cross-builder-with-raspbian-sysroot-compiling-with-the-sysroot-continued/
    rsync \
        -aP \
        --exclude '*android*' \
        --exclude 'hello_pi' \
        --exclude '.svn' \
        /src/opt/ /sysroot/opt/
}


function fetch_cross_compile_tool () {

    if [ ! -d "/src/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf" ]; then
        pushd /src/
        wget -q --progress=bar:force:noscroll --show-progress https://releases.linaro.org/components/toolchain/binaries/7.4-2019.02/arm-linux-gnueabihf/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf.tar.xz
        pv gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf.tar.xz | tar xpJ
        rm gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf.tar.xz
        popd
    fi
}

function fetch_qt6 () {

    /usr/games/cowsay -f tux "Fetching QT $QT_BRANCH."
    local SRC_DIR="/src/qt6"
    pushd /src 

    if [ ! -d "$SRC_DIR" ]; then
        mkdir -p "$SRC_DIR"

        wget -q --progress=bar:force:noscroll --show-progress https://download.qt.io/official_releases/qt/6.4/6.4.0/single/qt-everywhere-src-6.4.0.tar.xz
        pv qt-everywhere-src-6.4.0.tar.xz | tar xpJ -C "$SRC_DIR" --strip-components=1
        rm qt-everywhere-src-6.4.0.tar.xz
    else
        echo "DO NOTHING"
    fi
    popd
}

function build_qt () {
    
    pushd "$BUILD_TARGET"
    local SRC_DIR="/src/qt6"

    cmake "$SRC_DIR" -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DQT_BUILD_EXAMPLES=OFF \
        -DINPUT_opengl=es2 \
        -DQT_BUILD_TESTS=OFF \
        -DBUILD_qtdoc=OFF \
        -DBUILD_qttranslations=OFF \
        -DBUILD_qttools=OFF \
        -DBUILD_qtwebchannel=OFF \
        -DBUILD_qtwebengine=OFF \
        -DBUILD_qtwebview=OFF \
        -DBUILD_qtsensors=OFF \
        -DBUILD_qtvirtualkeyboard=OFF \
        -DBUILD_qtwebchannel=OFF \
        -DBUILD_qtspeech=OFF \
        -DCMAKE_INSTALL_PREFIX=/opt/qt6

    /usr/games/cowsay -f tux "Making QT version $QT_BRANCH."

    cmake --build . --parallel "$MAKE_CORES"

    /usr/games/cowsay -f tux "Installing QT version $QT_BRANCH."
    cmake --install .
    popd
}

fetch_rpi_firmware
fetch_cross_compile_tool
# Modify paths for build process
/usr/local/bin/sysroot-relativelinks.py /sysroot
fetch_qt6
build_qt