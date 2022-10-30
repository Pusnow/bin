#!/bin/bash

set -ex

gh-latest() {
    gh api repos/$1/$2/releases/latest -q .tag_name
}

echo "export FZF_VERSION=$(gh-latest junegunn fzf)"
echo "export HEXYL_VERSION=$(gh-latest sharkdp hexyl)"
echo "export DELTA_VERSION=$(gh-latest dandavison delta)"
echo "export NVIM_VERSION=$(gh-latest neovim neovim)"
echo "export RCLONE_VERSION=$(gh-latest rclone rclone)"
echo "export PANDOC_VERSION=$(gh-latest jgm pandoc)"
echo "export BPFTRACE_VERSION=$(gh-latest iovisor bpftrace)"
echo "export HADOLINT_VERSION=$(gh-latest hadolint hadolint)"
echo "export BAZELISK_VERSION=$(gh-latest bazelbuild bazelisk)"
echo "export JQ_VERSION=$(gh-latest stedolan jq)"
echo "export DUST_VERSION=$(gh-latest bootandy dust)"
echo "export FD_VERSION=$(gh-latest sharkdp fd)"
echo "export GH_VERSION=$(gh-latest cli cli)"
echo "export RG_VERSION=$(gh-latest BurntSushi ripgrep)"
echo "export KUBE_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)"
