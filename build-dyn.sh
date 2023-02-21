#!/bin/bash
set -ex

DISTRO=$1
DISTRO_VERSION=$2
ARCH=x64


VCMD["git"]=gh-latest-tag

gh-latest-tag() {
    gh api "repos/$1/$2/git/refs/tags" -q .[-1].ref.[10:]
}

${VCMD[$REPO]} git git >"${DISTRO}-${DISTRO_VERSION}-version-${ARCH}"
wget -qO - "https://github.com/Pusnow/bin/releases/download/bin/${DISTRO}-${DISTRO_VERSION}-version-${ARCH}"  >"${DISTRO}-${DISTRO_VERSION}-version-${ARCH}.old" || true
if diff -q "${DISTRO}-${DISTRO_VERSION}-version-${ARCH}" "${DISTRO}-${DISTRO_VERSION}-version-${ARCH}.old" &>/dev/null; then
    echo "Skipping upgrade..."
else
    GIT_VERSION=$(cat "${DISTRO}-${DISTRO_VERSION}-version-${ARCH}")

    docker build -t bin --build-arg DISTRO=${DISTRO} --build-arg VERSION=${DISTRO_VERSION} --build-arg GIT_VERSION=${GIT_VERSION:1} .
    docker run --rm --name bin -v${PWD}/build:/out bin cp -r /opt/pusnow.tar.gz /out

    if [ -n "${BIN_BUILD}" ]; then
        pushd "build"
        sudo mv pusnow.tar.gz "${DISTRO}-${DISTRO_VERSION}-${ARCH}.tar.gz"
        gh release upload bin "${DISTRO}-${DISTRO_VERSION}-${ARCH}.tar.gz" --clobber
        popd
        gh release upload bin "${DISTRO}-${DISTRO_VERSION}-version-${ARCH}" --clobber
    fi
fi
