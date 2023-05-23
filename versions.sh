#!/bin/bash

set -ex

export ARCH="${ARCH:-x64}"

gh-latest() {
    gh api "repos/$1/$2/releases/latest" -q .tag_name
}
gh-master() {
    gh api "repos/$1/$2/commits" -q ".[0].sha"
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
echo "HADOLINT_VERSION=$(gh-latest hadolint hadolint)"
echo "BAZELISK_VERSION=$(gh-latest bazelbuild bazelisk)"
echo "DUST_VERSION=$(gh-latest bootandy dust)"
echo "FD_VERSION=$(gh-latest sharkdp fd)"
echo "GH_VERSION=$(gh-latest cli cli)"
echo "RG_VERSION=$(gh-latest BurntSushi ripgrep)"
echo "NINJA_VERSION=$(gh-latest ninja-build ninja)"
echo "CMAKE_VERSION=$(curl -L -s "https://cmake.org/files/LatestRelease/cmake-latest-files-v1.json" | jq -r .version.string)"
echo "TOKEI_VERSION=$(gh-latest XAMPPRocky tokei)"
echo "DNSLOOKUP_VERSION=$(gh-latest ameshkov dnslookup)"
echo "CACERTS_VERSION=$(curl --etag-save /dev/stdout -sSL --remote-name https://curl.se/ca/cacert.pem)"
echo "NEOFETCH_VERSION=$(gh-latest dylanaraps neofetch)"
echo "SHFMT_VERSION=$(gh-latest mvdan sh)"
echo "SHELLCHECK_VERSION=$(gh-latest koalaman shellcheck)"
echo "DASEL_VERSION=$(gh-latest TomWright dasel)"
echo "BATSCORE_VERSION=$(gh-latest bats-core bats-core)"

echo "ZSTD_VERSION=$(pusnow-latest zstd)"
echo "LSHW_VERSION=$(pusnow-latest lshw)"
echo "SOCAT_VERSION=$(pusnow-latest socat)"
echo "SOCKPERF_VERSION=$(pusnow-latest sockperf)"
echo "IPERF_VERSION=$(pusnow-latest iperf)"
