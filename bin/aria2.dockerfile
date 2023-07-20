FROM cpp
ARG VERSION
RUN mkdir /build

RUN apk add --no-cache openssl-dev openssl-libs-static libxml2-dev libxml2-static nettle-dev nettle-static libssh2-dev libssh2-static c-ares-dev c-ares-static sqlite-dev sqlite-static expat-dev expat-static zlib-dev zlib-static libuv-dev libuv-static libgcrypt-dev libgcrypt-static xz-dev xz-static

RUN download-untar.sh aria2 z "https://github.com/aria2/aria2/releases/download/${VERSION}/aria2-${VERSION:8}.tar.gz"
RUN cd aria2 && ./configure --prefix=/opt/pusnow --disable-shared --disable-static --with-libuv ARIA2_STATIC=yes && make -j
RUN cd aria2 && make install
