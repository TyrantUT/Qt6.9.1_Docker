FROM --platform=linux/arm64/v8 debian:bookworm AS rpi-sysroot

ENV DEBIAN_FRONTEND='noninteractive'

RUN apt update && \
    apt install -y --no-install-recommends apt-utils && \
    apt install -y wget gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN wget -O- http://archive.raspberrypi.org/debian/raspberrypi.gpg.key | \
    gpg --dearmor | tee /etc/apt/keyrings/raspberrypi.gpg > /dev/null \
    && chmod 644 /etc/apt/keyrings/raspberrypi.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/raspberrypi.gpg] http://archive.raspberrypi.org/debian/ bookworm main" >> /etc/apt/sources.list \
    && sed -i '/^Types:/ s/\<deb\>\(.*\)\(\<deb-src\>\)\?/\0 deb-src/' /etc/apt/sources.list.d/debian.sources \
    && apt update

RUN apt install -y \
		libfontconfig1-dev libdbus-1-dev libfreetype6-dev libicu-dev libinput-dev libxkbcommon-dev libsqlite3-dev libssl-dev libpng-dev libjpeg-dev libglib2.0-dev libgles2-mesa-dev libgbm-dev libdrm-dev libx11-dev libxcb1-dev libxext-dev libxi-dev libxcomposite-dev libxcursor-dev libxtst-dev libxrandr-dev libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libxcb-xinput-dev libxcb-cursor-dev libatspi2.0-dev \
	&& dpkg --purge libraspberrypi-dev \
	&& apt-get autoremove --purge -y \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/*

FROM --platform=linux/amd64 debian:bookworm

LABEL maintain="christopher.radoumis@gmail.com"
LABEL description="Qt 6 cross-compiler Docker image for Raspberry Pi (arm64)"

ENV DEBIAN_FRONTEND='noninteractive'

RUN sed -i '/^Types:/ s/\<deb\>\(.*\)\(\<deb-src\>\)\?/\0 deb-src/' /etc/apt/sources.list.d/debian.sources \
	&& apt-get update

RUN apt install -y \
    bison build-essential clang cmake cowsay flex freeglut3-dev g++ g++-aarch64-linux-gnu gcc gcc-aarch64-linux-gnu git gperf libasound2-dev libassimp-dev libatspi2.0-dev libbluetooth-dev libboost-all-dev libcap-dev libclang-dev libdbus-1-dev libdouble-conversion-dev libdrm-dev libegl1-mesa-dev libevent-dev libfontconfig1-dev libfreetype6-dev libgl1-mesa-dev libglib2.0-dev libglu1-mesa-dev libgstreamer1.0-dev libharfbuzz-dev libhunspell-dev libicu-dev libjpeg-dev libnss3-dev libopengl-dev libopus-dev libpng-dev libpulse-dev libsqlite3-dev libssl-dev libtiff-dev libts-dev libvpx-dev libwayland-dev libx11-dev libx11-xcb-dev libxcb-glx0-dev libxcb-icccm4-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-shape0-dev libxcb-shm0-dev libxcb-sync-dev libxcb-util-dev libxcb-xfixes0-dev libxcb-xinerama0-dev libxcb-xinput-dev libxcb-xkb-dev libxcb1-dev libxcomposite-dev libxcursor-dev libxdamage-dev libxext-dev libxfixes-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev libxkbfile-dev libxrandr-dev libxrender-dev libxshmfence-dev libxshmfence1 libzstd-dev llvm lsb-release make ninja-build nodejs pkg-config pv python-is-python3 python3 re2c subversion symlinks wget zlib1g-dev \
    && apt autoremove --purge -y \
    && apt clean -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/* \
    && mkdir -p /sysroot/usr /sysroot/lib \
    && mkdir -p /build/qt-host /build/qt-raspi /build/qt-hostbuild /build/qtpi-build


WORKDIR /build

COPY --from=rpi-sysroot /lib/ /sysroot/lib/
COPY --from=rpi-sysroot /usr/include/ /sysroot/usr/include/
COPY --from=rpi-sysroot /usr/lib/ /sysroot/usr/lib/

COPY build_qt6Host.sh /usr/local/bin/
COPY build_qt6Rpi.sh /usr/local/bin/
COPY toolchain.cmake /build
RUN chmod +x /usr/local/bin/build_qt6Host.sh
RUN chmod +x /usr/local/bin/build_qt6Rpi.sh

#CMD /usr/local/bin/build_qt6Host.sh
#CMD /usr/local/bin/build_qt6Rpi.sh