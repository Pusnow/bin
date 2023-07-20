#!/bin/sh
mkdir -p "${1}"
wget -qO "${1}.tar.zz" "$3"
tar "-x${2}f" "${1}.tar.zz" -C "${1}"
strip-directory.sh "${1}"
