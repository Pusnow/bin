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

git-latest-tag() {
    TMPDIR=$(mktemp -d)
    git clone "$1" "${TMPDIR}"
    git -C "${TMPDIR}" describe --tags $(git -C "${TMPDIR}" rev-list --tags --max-count=1)
    rm -rf "${TMPDIR}"

}
git-latest-commit() {
    TMPDIR=$(mktemp -d)
    git clone "$1" "${TMPDIR}"
    git -C "${TMPDIR}" rev-parse HEAD
    rm -rf "${TMPDIR}"

}

set -ex

IMAGE=$1

if [ -z "$IMAGE" ]; then
    echo "No image"
    exit 1
fi

if [ -z "$ARCH" ]; then
    ARCH=x64
fi

arch() {
    if [[ "${ARCH}" == "x64" ]]; then
        echo $1
    elif [[ "${ARCH}" == "aarch64" ]]; then
        echo $2
    else
        echo "Unknown"
    fi
}

case $ARCH in
x64)
    IMAGE_ARCH="amd64"
    TAG_POSTFIX=""
    ;;
aarch64)
    IMAGE_ARCH="arm64"
    TAG_POSTFIX="-aarch64"
    ;;
*) IMAGE_ARCH="" ;;
esac

case $IMAGE in
socat) VERSION=$(git-latest-tag "git://repo.or.cz/socat.git") ;;
lshw) VERSION=$(git-latest-commit "https://github.com/lyonel/lshw.git") ;;
aria2) GH_REPO="aria2/aria2" ;;
iperf) VERSION=$(gh-latest-tag esnet iperf) ;;
sockperf) GH_REPO="Mellanox/sockperf" ;;
zstd) GH_REPO="facebook/zstd" ;;
hexyl) GH_REPO="sharkdp/hexyl" ;;
delta) GH_REPO="dandavison/delta" ;;
fd) GH_REPO="sharkdp/fd" ;;
ripgrep) GH_REPO="BurntSushi/ripgrep" ;;
dust) GH_REPO="bootandy/dust" ;;
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
hadolint)
    GH_REPO="hadolint/hadolint"
    VERSION_ARCH=$(arch x86_64 arm64)
    ;;
neofetch) GH_REPO="dylanaraps/neofetch" ;;
bats-core) GH_REPO="bats-core/bats-core" ;;
shellcheck)
    GH_REPO="koalaman/shellcheck"
    VERSION_ARCH=$(arch x86_64 aarch64)
    ;;
*) VERSION="" ;;
esac

if [ -z "${VERSION}" ] && [ -n "${GH_REPO}" ]; then
    VERSION=$(ghr-latest ${GH_REPO})
fi

if [ -n "${DOCKER_PATH}" ] && [ -n "${VERSION}" ] && [ "${GH_EVENT}" != "workflow_dispatch" ]; then

    if skopeo inspect "docker://${DOCKER_PATH}:${VERSION}${TAG_POSTFIX}" >/dev/null; then
        echo "already exists"
        exit 0
    fi

fi

buildah bud --arch "${IMAGE_ARCH}" -f base.dockerfile -t base helper

if [ -z "$BASE" ]; then
    case $IMAGE in
    aria2 | iperf | jq | lshw | neovim | ninja | socat | zstd) BASE="cpp" ;;
    dnslookup | fzf | gh | rclone | shfmt) BASE="go" ;;
    ruff | hexyl | delta | fd | ripgrep | tokei | dust) BASE="rust" ;;
    *) BASE="" ;;
    esac
fi

if [ -n "$BASE" ]; then
    buildah bud --arch "${IMAGE_ARCH}" -f $BASE.dockerfile -t $BASE helper
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

buildah bud --arch "${IMAGE_ARCH}" -t $IMAGE ${VERSION_ARGS} ${GH_REPO_ARGS} ${VERSION_ARCH_ARGS} - <"${DOCKERFILE}"

if [ -n "${DOCKER_PATH}" ]; then
    podman push $IMAGE "docker://${DOCKER_PATH}:latest${TAG_POSTFIX}"

    if [ -n "${VERSION}" ]; then
        podman push $IMAGE "docker://${DOCKER_PATH}:${VERSION}${TAG_POSTFIX}"

    fi
fi
