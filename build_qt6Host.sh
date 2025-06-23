#!/bin/bash

# vim: tabstop=4 shiftwidth=4 softtabstop=4
# -*- sh-basic-offset: 4 -*-

set -exuo pipefail

BUILD_TARGET=/build/qt-hostbuild
SRC=/src
QT_BRANCH_MAJOR="6.9"
QT_BRANCH_MINOR="1"
DEBIAN_VERSION=$(lsb_release -cs)
MAKE_CORES="$(expr $(nproc))"

mkdir -p "$BUILD_TARGET"
mkdir -p "$SRC"

/usr/games/cowsay -f tux "Building QT version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."

function fetch_qt6 () {

    /usr/games/cowsay -f tux "Fetching QT $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."
    
    local SRC_DIR="$SRC/qt6"
    pushd $SRC

    if [ ! -d "$SRC_DIR" ]; then
        mkdir -p "$SRC_DIR"

        wget --no-check-certificate -q --progress=bar:force:noscroll --show-progress "https://download.qt.io/official_releases/qt/$QT_BRANCH_MAJOR/$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR/single/qt-everywhere-src-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR.tar.xz"
        pv qt-everywhere-src-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR.tar.xz | tar xpJ -C "$SRC_DIR" --strip-components=1
        rm qt-everywhere-src-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR.tar.xz

        popd
    else
        echo "DO NOTHING"
        
        popd
    fi

}

function configure_qt () {

    pushd "$BUILD_TARGET"
    local SRC_DIR="/src/qt6"
    local TAG_FILE="/usr/local/build.tag"


    if [ ! -f "$TAG_FILE" ]; then

        # Modify paths for build process
        symlinks -rc /sysroot

        cmake "$SRC_DIR" -GNinja \
            -DCMAKE_BUILD_TYPE=Release \
            -DQT_BUILD_EXAMPLES=OFF \
            -DINPUT_opengl=es2 \
            -DQT_BUILD_TESTS=OFF \
            -DCMAKE_INSTALL_PREFIX=/build/qt-host \
            -DBUILD_qttools=OFF \
            -DBUILD_qtdoc=OFF \
            -DBUILD_qttranslations=OFF \
            -DBUILD_qtwebchannel=OFF \
            -DBUILD_qtwebengine=OFF \
            -DBUILD_qtwebview=OFF \
            -DBUILD_qtsensors=OFF \
            -DBUILD_qtvirtualkeyboard=OFF \
            -DBUILD_qtspeech=OFF \
            -DBUILD_qtsql=OFF \
            -DBUILD_qtxml=OFF \
            -DBUILD_qtimageformats=OFF \
            -DQT_FEATURE_jpeg=OFF \
            -DBUILD_qtlanguageserver=OFF \
            -DBUILD_qtwebsockets=OFF \
            -DBUILD_qthttpserver=OFF \
            -DBUILD_qtserialport=OFF \
            -DBUILD_qtpositioning=OFF \
            -DBUILD_qtlocation=OFF \
            -DBUILD_qtlottie=OFF \
            -DBUILD_qtmqtt=OFF \
            -DBUILD_qtremoteobjects=OFF \
            -DBUILD_qtserialbus=OFF \
            -DBUILD_qtsvg=OFF \
            -DBUILD_qtwayland=OFF \
            -DBUILD_qtcoap=OFF \
            -DBUILD_qt5compat=OFF \
            -DBUILD_qtconnectivity=OFF \
            -DBUILD_qtrpc=OFF \
            -DBUILD_qtopcua=OFF \
            -DBUILD_qtnetworkauth=OFF \
            -DBUILD_qtactiveqt=OFF \
            -DBUILD_qtgrpc=OFF \
            -DBUILD_qtscxml=OFF \
            -DCMAKE_CXX_FLAGS="-O2"

        touch "$TAG_FILE"

    else
        echo "DO NOTHING"
    fi
}

function cmake_qt () {
    pushd "$BUILD_TARGET"

    /usr/games/cowsay -f tux "Making QT version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR. with $MAKE_CORES Cores."

    cmake --build . --parallel "$MAKE_CORES" --verbose
}

function install_qt () {
    pushd "$BUILD_TARGET"

    /usr/games/cowsay -f tux "Installing QT version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."

    cmake --install .

    popd
}


# Get a fresh copy of QT
fetch_qt6

# Configure Qt
configure_qt

# Make Qt
cmake_qt

# Install Qt
install_qt