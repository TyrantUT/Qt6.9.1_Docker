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
BUILT_TARGET_PI=/built

mkdir -p "$BUILT_TARGET_PI"
mkdir -p "$BUILD_TARGET_PI"

/usr/games/cowsay -f tux "Building QT version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."

function build_qtpi () {
    local SRC_DIR="$SRC/qt6"

    pushd "$BUILD_TARGET_PI"

    cmake $SRC_DIR -GNinja \
        -DCMAKE_BUILD_TYPE=Release \
        -DINPUT_opengl=es2 \
        -DQT_FEATURE_kms=ON \
        -DQT_FEATURE_opengles2=ON \
        -DQT_FEATURE_opengles3=ON \
        -DQT_FEATURE_jpeg=OFF \
        -DQT_FEATURE_eglfs=ON \
        -DQT_FEATURE_xcb=ON \
        -DQT_FEATURE_xlib=ON \
        -DQT_FEATURE_opensource=ON \
        -DQT_FEATURE_pkg_config=ON \
        -DQT_FEATURE_pcre2=ON \
        -DQT_FEATURE_precompiled_headers=OFF \
        -DQT_FEATURE_evdev=ON \
        -DQT_FEATURE_system_freetype=ON \
        -DQT_FEATURE_fontconfig=ON \
        -DQT_FEATURE_glib=ON \
        -DQT_FEATURE_cups=OFF \
        -DQT_FEATURE_gtk3=OFF \
        -DQT_FEATURE_gold_linker=OFF \
        -DQT_BUILD_EXAMPLES=OFF \
        -DQT_BUILD_TESTS=OFF \
        -DQT_QPA_DEFAULT_PLATFORM=eglfs \
        -DFEATURE_xcb_xlib=ON \
        -DBUILD_WITH_PCH=OFF \
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
        -DBUILD_qtquicktimeline=OFF \
        -DBUILD_qtquick3d=OFF \
        -DBUILD_qtmultimedia=OFF \
        -DBUILD_qt3d=OFF \
        -DBUILD_qtdatavis3d=OFF \
        -DBUILD_qtquick3dphysics=OFF \
        -DBUILD_qtquickeffectmaker=OFF \
        -DBUILD_qtgraphs=OFF \
        -DQT_HOST_PATH=/build/qt-host \
        -DCMAKE_STAGING_PREFIX=/build/qt-raspi \
        -DCMAKE_INSTALL_PREFIX=/usr/local/qt6 \
        -DCMAKE_PREFIX_PATH=/build/qt-host/lib/cmake \
        -DCMAKE_TOOLCHAIN_FILE=/build/toolchain.cmake \
        -DQT_QMAKE_TARGET_MKSPEC=devices/linux-rasp-pi4-aarch64 \
        -DCMAKE_SYSROOT=/sysroot \
        -DQT_AVOID_CMAKE_ARCHIVING_API=ON \
        -DCMAKE_CXX_FLAGS="-O2"


    /usr/games/cowsay -f tux "Making QT Pi version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."

    cmake --build . --parallel "$MAKE_CORES"

    /usr/games/cowsay -f tux "Installing QT Pi version $QT_BRANCH_MAJOR.$QT_BRANCH_MINOR."
    cmake --install .
    popd

    pushd "$SRC_DIR"
    tar cfz "$BUILT_TARGET_PI/qt6-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION-$1.tar.gz" qt6pi
    popd

    pushd "$BUILT_TARGET_PI"
    sha256sum "qt6-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION-$1.tar.gz" > "qt6-$QT_BRANCH_MAJOR.$QT_BRANCH_MINOR-$DEBIAN_VERSION-$1.tar.gz.sha256"
    popd
}

build_qtpi