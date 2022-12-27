#!/bin/bash
set -ex

export BUILD_PATH=build
export BUILD_REAL_PATH=$(realpath build)
export SRC_PATH=src
export ARCH="${ARCH:-x64}"

declare -A OWNERS
OWNERS["aria2"]=aria2
OWNERS["zstd"]=facebook

gh-latest() {
    gh api "repos/$1/$2/releases/latest" -q .tag_name
}
pusnow-latest() {
    wget -qO - "https://github.com/Pusnow/bin/releases/download/bin/$1-version" || true
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

aria2() {
    download-git aria2 "${VERSION}" "https://github.com/aria2/aria2.git"
    pushd "${SRC_PATH}/aria2"
    autoreconf -i
    ./configure ARIA2_STATIC=yes --prefix="${BUILD_REAL_PATH}/aria2"
    make -j
    make install
    popd
}

zstd() {
    download-untar zstd z "https://github.com/facebook/zstd/releases/download/${VERSION}/zstd-${VERSION:1}.tar.gz"
    pushd "${SRC_PATH}/zstd"

    pushd build/cmake
    mkdir builddir
    pushd builddir
    cmake -DZSTD_USE_STATIC_RUNTIME=ON -DCMAKE_INSTALL_PREFIX="${BUILD_REAL_PATH}/zstd" ..
    make -j
    make install
    popd
    popd
    popd
}

REPO=$1
OWNER=${OWNERS[$REPO]}
gh-latest "${OWNER}" "${REPO}" >"${REPO}-version-${ARCH}"
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
