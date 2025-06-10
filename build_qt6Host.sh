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

        git clone https://code.qt.io/qt/qt5.git $SRC_DIR

        pushd $SRC_DIR

        git switch $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR
        perl init-repository --module-subset=qtbase,qtcharts,qtdeclarative,qtgraphs,qtquick3d,qtshadertools

        popd
    else
        echo "DO NOTHING"
    fi
    popd
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