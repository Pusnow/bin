#!/bin/bash

gh-latest() {
    gh api "repos/$1/$2/releases/latest" -q .tag_name
}
ghr-latest() {
    gh api "repos/$1/releases/latest" -q .tag_name
}
gh-master() {
    gh api "repos/$1/$2/commits" -q ".[0].sha"
}
gh-latest-tag() {
    gh api "repos/$1/$2/git/refs/tags" -q .[-1].ref.[10:]
}

set -ex

IMAGE=$1
ARCH=$2

if [ -z "$IMAGE" ]; then
    echo "No image"
    exit 1
fi

if [ -z "$ARCH" ]; then
    ARCH=x86_64
fi

arch() {
    if [[ "${ARCH}" == "x86_64" ]]; then
        echo $1
    elif [[ "${ARCH}" == "aarch64" ]]; then
        echo $2
    else
        echo "Unknown"
    fi
}

podman build -f base.dockerfile -t base helper
if [ -n "$BASE" ]; then
    podman build -f $BASE.dockerfile -t $BASE helper
fi

case $IMAGE in
aria2) GH_REPO="aria2/aria2" ;;
iperf) VERSION=$(gh-latest-tag esnet iperf) ;;
sockperf) VERSION=$(gh-latest Mellanox sockperf) ;;
zstd) GH_REPO="facebook/zstd" ;;
hexyl) GH_REPO="sharkdp/hexyl" ;;
delta) GH_REPO="dandavison/delta" ;;
fd) GH_REPO="sharkdp/fd" ;;
ripgrep) GH_REPO="BurntSushi/ripgrep" ;;
tokei) GH_REPO="XAMPPRocky/tokei" ;;
ruff) GH_REPO="astral-sh/ruff" ;;
fzf) GH_REPO="junegunn/fzf" ;;
gh) GH_REPO="cli/cli" ;;
dnslookup) GH_REPO="ameshkov/dnslookup" ;;
shfmt) GH_REPO="mvdan/sh" ;;
neovim) GH_REPO="neovim/neovim" ;;
jq) GH_REPO="jqlang/jq" ;;
rclone) GH_REPO="rclone/rclone" ;;
ninja) GH_REPO="ninja-build/ninja" ;;
pandoc)
    GH_REPO="jgm/pandoc"
    VERSION_ARCH=$(arch amd64 arm64)
    ;;
cmake)
    GH_REPO="Kitware/CMake"
    VERSION_ARCH=$(arch x86_64 aarch64)
    ;;
*) VERSION="" ;;
esac

if [ -z "${VERSION}" ] && [ -n "${GH_REPO}" ]; then
    VERSION=$(ghr-latest ${GH_REPO})
fi

VERSION_ARGS=""
if [ -n "${VERSION}" ]; then
    VERSION_ARGS="--build-arg VERSION=${VERSION}"
fi

GH_REPO_ARGS=""
if [ -n "${GH_REPO}" ]; then
    GH_REPO_ARGS="--build-arg GH_REPO=${GH_REPO}"
fi

VERSION_ARCH_ARGS=""
if [ -n "${VERSION_ARCH}" ]; then
    VERSION_ARCH_ARGS="--build-arg VERSION_ARCH=${VERSION_ARCH}"
fi

DOCKERFILE=""
if [ -f "bin/${IMAGE}.dockerfile" ]; then
    DOCKERFILE="bin/${IMAGE}.dockerfile"
elif [ -n "${BASE}" ]; then
    DOCKERFILE="bin/${BASE}-default.dockerfile"
fi

podman build -t $IMAGE ${VERSION_ARGS} ${GH_REPO_ARGS} ${VERSION_ARCH_ARGS} - <"${DOCKERFILE}"
