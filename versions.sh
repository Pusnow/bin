#!/bin/bash

set -ex

gh-latest() {
    gh api "repos/$1/$2/releases/latest" -q .tag_name
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
