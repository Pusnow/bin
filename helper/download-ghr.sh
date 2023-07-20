#!/bin/sh
mkdir -p "${1}"
wget -qO "${1}.tar.gz" "https://github.com/${1}/archive/refs/tags/${2}.tar.gz"
tar "-xzf" "${1}.tar.gz" -C "${1}"
strip-directory.sh "${1}"
