#!/bin/bash
set -ex

export BUILD_PATH=build
export BUILD_REAL_PATH=$(realpath build)
export LOCAL_PATH=local
export LOCAL_REAL_PATH=$(realpath local)
export SRC_PATH=src
export ARCH="${ARCH:-x64}"

declare -A OWNERS
OWNERS["aria2"]=aria2
OWNERS["zstd"]=facebook
OWNERS["lshw"]=lyonel
OWNERS["socat"]="git://repo.or.cz/socat.git"
OWNERS["sockperf"]=Mellanox

declare -A VCMD
VCMD["aria2"]=gh-latest
VCMD["zstd"]=gh-latest
VCMD["lshw"]=gh-master
VCMD["socat"]=git-latest-tag
VCMD["sockperf"]=gh-latest

gh-latest() {
    gh api "repos/$1/$2/releases/latest" -q .tag_name
}
gh-master() {
    gh api "repos/$1/$2/commits" -q ".[0].sha"
}
git-latest-tag() {
    TMPDIR=$(mktemp -d)
    git clone "$1" "${TMPDIR}"
    git -C "${TMPDIR}" describe --tags $(git -C "${TMPDIR}" rev-list --tags --max-count=1)
    rm -rf "${TMPDIR}"
}
pusnow-latest() {
    wget -qO - "https://github.com/Pusnow/bin/releases/download/bin/$1-version-${ARCH}" || true
}

strip-directory() {
    NE=$(find "${1}" -maxdepth 1 -mindepth 1 | wc -l | xargs || true)
    ND=$(find "${1}" -maxdepth 1 -mindepth 1 -type d | wc -l | xargs || true)

    if [[ "${NE}" == "1" ]] && [[ "${ND}" == "1" ]]; then
        DIR=$(find "${1}" -maxdepth 1 -mindepth 1)
        mv "${DIR}/"* "${1}"
        rm -r "${DIR}"
    fi

}
download-untar() {
    mkdir -p "${SRC_PATH}/${1}"
    wget -qO "${SRC_PATH}/${1}.tar.zz" "$3"
    tar "-x${2}f" "${SRC_PATH}/${1}.tar.zz" -C "${SRC_PATH}/${1}"
    strip-directory "${SRC_PATH}/${1}"
}

download-git() {
    git clone --recursive -b "${2}" --depth 1 "${3}" "${SRC_PATH}/${1}"
}

install-openssl() {
    # openssl
    download-untar ssl z https://www.openssl.org/source/openssl-1.1.1s.tar.gz
    pushd "${SRC_PATH}/ssl"
    ./config --prefix="${LOCAL_REAL_PATH}" no-shared
    make -j4
    make install_sw
    popd

}

aria2() {
    install-openssl
    # libc-cares
    download-untar cares z https://github.com/c-ares/c-ares/releases/download/cares-1_18_1/c-ares-1.18.1.tar.gz
    pushd "${SRC_PATH}/cares"
    ./configure \
        --disable-shared \
        --enable-static \
        --without-random \
        --prefix="${LOCAL_REAL_PATH}"
    make -j4
    make install
    popd
    # # libexpat
    download-untar expat z https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.gz
    pushd "${SRC_PATH}/expat"
    ./configure \
        --disable-shared \
        --enable-static \
        --prefix="${LOCAL_REAL_PATH}"
    make -j4
    make install
    popd

    # # zlib1g
    download-untar zlib z https://github.com/madler/zlib/releases/download/v1.2.13/zlib-1.2.13.tar.gz
    pushd "${SRC_PATH}/zlib"
    ./configure \
        --prefix="${LOCAL_REAL_PATH}" \
        --libdir="${LOCAL_REAL_PATH}/lib" \
        --includedir="${LOCAL_REAL_PATH}/include" \
        --static
    make -j4
    make install
    popd

    # # libsqlite3
    download-untar sqlite z https://www.sqlite.org/2022/sqlite-autoconf-3400000.tar.gz
    pushd "${SRC_PATH}/sqlite"
    ./configure \
        --disable-shared \
        --enable-static \
        --prefix="${LOCAL_REAL_PATH}"
    make -j4
    make install
    popd

    download-untar aria2 z https://github.com/aria2/aria2/releases/download/${VERSION}/aria2-${VERSION:8}.tar.gz
    pushd "${SRC_PATH}/aria2"
    export PKG_CONFIG_PATH="${LOCAL_REAL_PATH}/lib/pkgconfig"
    ./configure --prefix="${BUILD_REAL_PATH}/aria2" \
        --without-libxml2 \
        --without-gnutls \
        --without-libxml2 \
        --without-libnettle \
        --without-libssh2 \
        --with-openssl --with-openssl-prefix="${LOCAL_REAL_PATH}" \
        --with-libcares --with-libcares-prefix="${LOCAL_REAL_PATH}" \
        --with-sqlite3 --with-sqlite3-prefix="${LOCAL_REAL_PATH}" \
        --with-libexpat --with-libexpat-prefix="${LOCAL_REAL_PATH}" \
        --with-libz --with-libz-prefix="${LOCAL_REAL_PATH}" \
        ARIA2_STATIC=yes
    make -j4
    make install
    popd
}

zstd() {
    pip install --user meson ninja
    download-untar zstd z "https://github.com/facebook/zstd/releases/download/${VERSION}/zstd-${VERSION:1}.tar.gz"
    pushd "${SRC_PATH}/zstd/build/meson"

    LDFLAGS=-static meson setup \
        --prefix "${BUILD_REAL_PATH}/zstd" \
        -Dbin_programs=true \
        -Dstatic_runtime=true \
        -Ddefault_library=static \
        -Dzlib=disabled -Dlzma=disabled -Dlz4=disabled \
        builddir
    pushd builddir
    ninja
    ninja install
    popd
    popd
}

lshw() {
    download-git lshw master https://github.com/lyonel/lshw.git
    pushd "${SRC_PATH}/lshw"
    rm src/manuf.txt src/oui.txt src/pci.ids src/pnp.ids src/usb.ids
    make static PREFIX=/tmp/hwdata
    mkdir -p "${BUILD_REAL_PATH}/lshw/hwdata"
    pushd src
    make manuf.txt oui.txt pci.ids pnp.ids usb.ids
    cp "lshw-static" "${BUILD_REAL_PATH}/lshw/lshw"
    cp "lshw.1" "${BUILD_REAL_PATH}/lshw/lshw.1"
    cp "manuf.txt" "${BUILD_REAL_PATH}/lshw/hwdata/manuf.txt"
    cp "oui.txt" "${BUILD_REAL_PATH}/lshw/hwdata/oui.txt"
    cp "pci.ids" "${BUILD_REAL_PATH}/lshw/hwdata/pci.ids"
    cp "pnp.ids" "${BUILD_REAL_PATH}/lshw/hwdata/pnp.ids"
    cp "pnpid.txt" "${BUILD_REAL_PATH}/lshw/hwdata/pnpid.txt"
    cp "usb.ids" "${BUILD_REAL_PATH}/lshw/hwdata/usb.ids"
    popd
    popd
}

socat() {
    sudo apt-get update && sudo apt-get install -y yodl
    install-openssl
    download-git socat "${VERSION}" "git://repo.or.cz/socat.git"
    pushd "${SRC_PATH}/socat"
    autoconf
    export PKG_CONFIG_PATH="${LOCAL_REAL_PATH}/lib/pkgconfig"
    LDFLAGS=-static ./configure --prefix="${BUILD_REAL_PATH}/socat"
    make -j4
    make install
    popd
}

sockperf() {
    sudo apt-get update && sudo apt-get install -y doxygen
    download-untar sockperf z "https://github.com/Mellanox/sockperf/archive/refs/tags/${VERSION}.tar.gz"
    pushd "${SRC_PATH}/sockperf"
    ./autogen.sh
    LDFLAGS=-static ./configure \
        --disable-shared \
        --enable-static \
        --enable-doc \
        --enable-tool \
        --prefix="${BUILD_REAL_PATH}/sockperf"
    make LDFLAGS=-all-static -j4
    make install
    popd
}
REPO=$1
OWNER=${OWNERS[$REPO]}
${VCMD[$REPO]} "${OWNER}" "${REPO}" >"${REPO}-version-${ARCH}"
pusnow-latest "${REPO}" >"${REPO}-version-${ARCH}.old"
if diff -q "${REPO}-version-${ARCH}" "${REPO}-version-${ARCH}.old" &>/dev/null; then
    echo "Skipping upgrade..."
else
    VERSION=$(cat ${REPO}-version-${ARCH})
    $1
    pushd "build"
    tar -cvzf "${REPO}-${ARCH}.tar.gz" "${REPO}"
    gh release upload bin "${REPO}-${ARCH}.tar.gz" --clobber
    popd
    gh release upload bin "${REPO}-version-${ARCH}" --clobber
fi
