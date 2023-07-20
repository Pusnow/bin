FROM cpp
ARG VERSION
ARG GH_REPO
RUN mkdir /build

RUN download-ghr.sh ${GH_REPO} ${VERSION}

RUN apk add --no-cache openssl-dev openssl-libs-static libxml2-dev libxml2-static nettle-dev nettle-static libssh2-dev libssh2-static c-ares-dev c-ares-static sqlite-dev sqlite-static expat-dev expat-static zlib-dev zlib-static libuv-dev libuv-static libgcrypt-dev libgcrypt-static xz-dev xz-static

RUN cd ${GH_REPO} && ./configure --prefix=/opt/pusnow --disable-shared --disable-static --with-libuv ARIA2_STATIC=yes && make -j
RUN cd ${GH_REPO} && make install
