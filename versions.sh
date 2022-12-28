#!/bin/bash

set -ex

export ARCH="${ARCH:-x64}"

gh-latest() {
    gh api "repos/$1/$2/releases/latest" -q .tag_name
}
pusnow-latest() {
    wget -qO - "https://github.com/Pusnow/bin/releases/download/bin/$1-version-${ARCH}" || true
}

echo "FZF_VERSION=$(gh-latest junegunn fzf)"
echo "HEXYL_VERSION=$(gh-latest sharkdp hexyl)"
echo "DELTA_VERSION=$(gh-latest dandavison delta)"
echo "NVIM_VERSION=$(gh-latest neovim neovim)"
echo "RCLONE_VERSION=$(gh-latest rclone rclone)"
echo "PANDOC_VERSION=$(gh-latest jgm pandoc)"
echo "BPFTRACE_VERSION=$(gh-latest iovisor bpftrace)"
echo "HADOLINT_VERSION=$(gh-latest hadolint hadolint)"
echo "BAZELISK_VERSION=$(gh-latest bazelbuild bazelisk)"
echo "JQ_VERSION=$(gh-latest stedolan jq)"
echo "DUST_VERSION=$(gh-latest bootandy dust)"
echo "FD_VERSION=$(gh-latest sharkdp fd)"
echo "GH_VERSION=$(gh-latest cli cli)"
echo "RG_VERSION=$(gh-latest BurntSushi ripgrep)"
echo "KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)"
echo "NINJA_VERSION=$(gh-latest ninja-build ninja)"
echo "CMAKE_VERSION=$(curl -L -s "https://cmake.org/files/LatestRelease/cmake-latest-files-v1.json" | jq -r .version.string)"
echo "HUGO_VERSION=$(gh-latest gohugoio hugo)"
echo "TOKEI_VERSION=$(gh-latest XAMPPRocky tokei)"
echo "DNSLOOKUP_VERSION=$(gh-latest ameshkov dnslookup)"
echo "ZSTD_VERSION=$(pusnow-latest zstd)"
echo "ARIA2_VERSION=$(pusnow-latest aria2)"
