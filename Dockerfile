ARG DISTRO
ARG VERSION

FROM ${DISTRO}:${VERSION}

ARG GIT_VERSION=2.39.2
ARG CURL_VERSION=7.87.0
ARG ZLIB_VERSION=1.2.13
ARG EXPAT_VERSION=2.5.0
ARG EXPAT_VERSION_2=2_5_0
ARG OPENSSL_VERSION=1.1.1s

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends asciidoc gettext wget ca-certificates perl build-essential pkg-config autoconf automake xmlto


RUN mkdir -p "/build/openssl" && \
    wget -qO "/root/openssl.tar.gz" "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" && \
    tar "--strip-components=1" "-xzf" "/root/openssl.tar.gz" -C  "/build/openssl" && \
    cd "/build/openssl" && \
    ./config --prefix="/opt/pusnow" && \
    make -j4 && \
    make install_sw

RUN mkdir -p "/build/expat" && \
    wget -qO "/root/expat.tar.gz" "https://github.com/libexpat/libexpat/releases/download/R_${EXPAT_VERSION_2}/expat-${EXPAT_VERSION}.tar.gz" && \
    tar "--strip-components=1" "-xzf" "/root/expat.tar.gz" -C  "/build/expat" && \
    cd "/build/expat" && \
    ./configure --prefix="/opt/pusnow" && \
    make -j4 && \
    make install

RUN mkdir -p "/build/curl" && \
    wget -qO "/root/curl.tar.gz" "https://curl.se/download/curl-${CURL_VERSION}.tar.gz" && \
    tar "--strip-components=1" "-xzf" "/root/curl.tar.gz" -C  "/build/curl" && \
    cd "/build/curl" && \
    env PKG_CONFIG_PATH="/opt/pusnow/lib/pkgconfig" ./configure --prefix="/opt/pusnow" --with-openssl && \
    make -j4 && \
    make install

RUN mkdir -p "/build/zlib" && \
    wget -qO "/root/zlib.tar.gz" "https://github.com/madler/zlib/releases/download/v${ZLIB_VERSION}/zlib-${ZLIB_VERSION}.tar.gz" && \
    tar "--strip-components=1" "-xzf" "/root/zlib.tar.gz" -C  "/build/zlib" && \
    cd "/build/zlib" && \
    env PKG_CONFIG_PATH="/opt/pusnow/lib/pkgconfig" ./configure --prefix="/opt/pusnow" && \
    make -j4 && \
    make install

RUN mkdir -p "/build/git" && \
    wget -qO "/root/git.tar.gz" "https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz" && \
    tar "--strip-components=1" "-xzf" "/root/git.tar.gz" -C  "/build/git" && \
    cd "/build/git" && \
    make configure && \
    env PATH="/opt/pusnow/bin:$PATH"  ./configure --prefix="/opt/pusnow" --without-tcltk --with-openssl=/opt/pusnow  --with-curl=/opt/pusnow --with-expat=/opt/pusnow --with-zlib=/opt/pusnow  && \
    make -j4 && \
    make man -j4 && \
    make install && \
    make install-man

RUN cd "/opt" && \
    tar -cvzf pusnow.tar.gz pusnow 