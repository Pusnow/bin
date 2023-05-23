#!/bin/bash

set -ex

export BUILD_PATH=build
export EXTRACT_PATH=extract
export ARCH="${ARCH:-x64}"

strip-directory() {
    NE=$(find "${1}" -maxdepth 1 -mindepth 1 | wc -l | xargs || true)
    ND=$(find "${1}" -maxdepth 1 -mindepth 1 -type d | wc -l | xargs || true)
    if [[ "${NE}" == "1" ]] && [[ "${ND}" == "1" ]]; then
        DIR=$(find "${1}" -maxdepth 1 -mindepth 1)
        rm -rf "/tmp/stripping"
        mv "${DIR}" "/tmp/stripping"
        rm -r "${1}"
        mv "/tmp/stripping" "${1}"
    fi

}

download-file() {
    mkdir -p "${EXTRACT_PATH}/${1}"
    wget -qO "${EXTRACT_PATH}/${1}/${1}" "$2"
}

download-untar() {
    mkdir -p "${EXTRACT_PATH}/${1}"
    wget -qO "${EXTRACT_PATH}/${1}.tar.zz" "$3"
    tar "-x${2}f" "${EXTRACT_PATH}/${1}.tar.zz" -C "${EXTRACT_PATH}/${1}"
    strip-directory "${EXTRACT_PATH}/${1}"
}
download-unzip() {
    mkdir -p "${EXTRACT_PATH}/${1}"
    wget -qO "${EXTRACT_PATH}/${1}.zip" "$2"
    unzip -o -d "${EXTRACT_PATH}/${1}" "${EXTRACT_PATH}/${1}.zip"
    strip-directory "${EXTRACT_PATH}/${1}"
}

install-all() {
    cp -prv "${1}/"* "${BUILD_PATH}"

}
install-bin() {
    chmod +x "${1}"
    cp -prv "${1}" "${BUILD_PATH}/bin/"
}

install-bin-dir() {
    chmod +x "${1}/"*
    cp -prv "${1}/"* "${BUILD_PATH}/bin/"
}

install-man() {
    if [[ ! -d "${BUILD_PATH}/share/man/man${1}/" ]]; then
        mkdir -p "${BUILD_PATH}/share/man/man${1}/"
    fi
    cp -prv "${2}" "${BUILD_PATH}/share/man/man${1}/"
}
install-man-dir() {
    if [[ ! -d "${BUILD_PATH}/share/man/man${1}/" ]]; then
        mkdir -p "${BUILD_PATH}/share/man/man${1}/"
    fi
    cp -prv "${2}/"* "${BUILD_PATH}/share/man/man${1}/"
}

install-bash-c() {
    cp -prv "${2}" "${BUILD_PATH}/share/bash_completion.d/${1}.bash"
}
install-zsh-c() {
    cp -prv "${2}" "${BUILD_PATH}/share/zsh_completion.d/_${1}"
}

download-install-man() {
    wget -qO "/tmp/${2}" "${3}"
    install-man "${1}" "/tmp/${2}"
}

download-install-bash-c() {
    wget -qO "/tmp/${1}.bash" "${2}"
    install-bash-c "${1}" "/tmp/${1}.bash"
}

download-install-zsh-c() {
    wget -qO "/tmp/_${1}" "${2}"
    install-zsh-c "${1}" "/tmp/_${1}"
}

if [[ ! -f versions ]]; then
    ./versions.sh >versions
fi

source versions

arch() {

    if [[ "${ARCH}" == "x64" ]]; then
        echo $1
    elif [[ "${ARCH}" == "aarch64" ]]; then
        echo $2
    else
        echo "Unknown"
    fi
}

download() {
    mkdir -p "${EXTRACT_PATH}"
    download-untar fzf z "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_$(arch amd64 arm64).tar.gz"
    download-untar hexyl z "https://github.com/sharkdp/hexyl/releases/download/${HEXYL_VERSION}/hexyl-${HEXYL_VERSION}-$(arch x86_64 aarch64)-unknown-linux-gnu.tar.gz"
    download-untar delta z "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-$(arch x86_64 aarch64)-unknown-linux-gnu.tar.gz"
    if [[ "${ARCH}" == "x64" ]]; then
        download-untar nvim z "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux$(arch 64).tar.gz"
    fi

    download-unzip rclone "https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-$(arch amd64 arm64).zip"

    download-untar pandoc z "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-$(arch amd64 arm64).tar.gz"

    download-file hadolint "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-$(arch x86_64 arm64)"
    download-file bazel "https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-$(arch amd64 arm64)"

    download-untar dust z "https://github.com/bootandy/dust/releases/download/${DUST_VERSION}/dust-${DUST_VERSION}-$(arch x86_64 aarch64)-unknown-linux-gnu.tar.gz"
    download-untar fd z "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-${FD_VERSION}-$(arch x86_64 aarch64)-unknown-linux-gnu.tar.gz"
    download-untar gh z "https://github.com/cli/cli/releases/download/${GH_VERSION}/gh_${GH_VERSION:1}_linux_$(arch amd64 arm64).tar.gz"
    if [[ "${ARCH}" == "x64" ]]; then
        download-untar rg z "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-$(arch x86_64)-unknown-linux-musl.tar.gz"
    fi

    if [[ "${ARCH}" == "x64" ]]; then
        download-unzip ninja "https://github.com/ninja-build/ninja/releases/download/${NINJA_VERSION}/ninja-linux.zip"
    fi
    download-untar cmake z "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-$(arch x86_64 aarch64).tar.gz"

    download-untar tokei z "https://github.com/XAMPPRocky/tokei/releases/download/${TOKEI_VERSION}/tokei-$(arch x86_64 aarch64)-unknown-linux-gnu.tar.gz"
    download-untar dnslookup z "https://github.com/ameshkov/dnslookup/releases/download/${DNSLOOKUP_VERSION}/dnslookup-linux-$(arch amd64 arm64)-${DNSLOOKUP_VERSION}.tar.gz"

    download-untar neofetch z "https://github.com/dylanaraps/neofetch/archive/refs/tags/${NEOFETCH_VERSION}.tar.gz"

    download-file shfmt "https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_$(arch amd64 arm64)"

    download-untar shellcheck J "https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.$(arch x86_64 aarch64).tar.xz"

    download-file dasel "https://github.com/TomWright/dasel/releases/download/${DASEL_VERSION}/dasel_linux_$(arch amd64 arm64)"

    download-untar batscore z "https://github.com/bats-core/bats-core/archive/refs/tags/${BATSCORE_VERSION}.tar.gz"

    if [[ "${ARCH}" == "x64" ]]; then
        download-untar zstd z "https://github.com/Pusnow/bin/releases/download/bin/zstd-$(arch x64).tar.gz"
        download-untar lshw z "https://github.com/Pusnow/bin/releases/download/bin/lshw-$(arch x64).tar.gz"
        download-untar socat z "https://github.com/Pusnow/bin/releases/download/bin/socat-$(arch x64).tar.gz"
        download-untar sockperf z "https://github.com/Pusnow/bin/releases/download/bin/sockperf-$(arch x64).tar.gz"
        mv "${EXTRACT_PATH}/sockperf/sbin/"* "${EXTRACT_PATH}/sockperf/bin/"
        rm -rf "${EXTRACT_PATH}/sockperf/sbin/"
        rm -rf "${EXTRACT_PATH}/sockperf/share/doc"
        download-untar iperf z "https://github.com/Pusnow/bin/releases/download/bin/iperf-$(arch x64).tar.gz"
    fi

    wait
}
install() {
    mkdir -p "${BUILD_PATH}/bin"
    mkdir -p "${BUILD_PATH}/share/bash_plugin.d" "${BUILD_PATH}/share/zsh_plugin.d"
    mkdir -p "${BUILD_PATH}/share/bash_completion.d" "${BUILD_PATH}/share/zsh_completion.d"

    install-bin "${EXTRACT_PATH}/fzf/fzf"
    wget -qO "${BUILD_PATH}/share/bash_plugin.d/fzf-keybindings.bash" "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/key-bindings.bash"
    wget -qO "${BUILD_PATH}/share/zsh_plugin.d/fzf-keybindings.zsh" "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/key-bindings.zsh"
    download-install-man 1 fzf.1 "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/man/man1/fzf.1"
    download-install-man 1 fzf-tmux.1 "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/man/man1/fzf-tmux.1"
    download-install-bash-c fzf "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/completion.bash"
    download-install-zsh-c fzf "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/completion.zsh"

    install-bin "${EXTRACT_PATH}/hexyl/hexyl"
    install-man 1 "${EXTRACT_PATH}/hexyl/hexyl.1"

    install-bin "${EXTRACT_PATH}/delta/delta"
    download-install-bash-c delta "https://raw.githubusercontent.com/dandavison/delta/${DELTA_VERSION}/etc/completion/completion.bash"
    download-install-zsh-c delta "https://raw.githubusercontent.com/dandavison/delta/${DELTA_VERSION}/etc/completion/completion.zsh"

    if [[ "${ARCH}" == "x64" ]]; then
        install-all "${EXTRACT_PATH}/nvim"
    fi

    install-bin "${EXTRACT_PATH}/rclone/rclone"
    install-man 1 "${EXTRACT_PATH}/rclone/rclone.1"

    install-all "${EXTRACT_PATH}/pandoc"

    install-bin "${EXTRACT_PATH}/hadolint/hadolint"

    install-bin "${EXTRACT_PATH}/bazel/bazel"

    install-bin "${EXTRACT_PATH}/dust/dust"

    install-bin "${EXTRACT_PATH}/fd/fd"
    install-man 1 "${EXTRACT_PATH}/fd/fd.1"
    install-bash-c fd "${EXTRACT_PATH}/fd/autocomplete/fd.bash"
    install-zsh-c fd "${EXTRACT_PATH}/fd/autocomplete/_fd"

    install-all "${EXTRACT_PATH}/gh"

    if [[ "${ARCH}" == "x64" ]]; then
        install-bin "${EXTRACT_PATH}/rg/rg"
        install-bash-c rg "${EXTRACT_PATH}/rg/complete/rg.bash"
        install-zsh-c rg "${EXTRACT_PATH}/rg/complete/_rg"
    fi

    if [[ "${ARCH}" == "x64" ]]; then
        install-bin "${EXTRACT_PATH}/ninja/ninja"
    fi

    install-bin-dir "${EXTRACT_PATH}/cmake/bin"
    install-man-dir 1 "${EXTRACT_PATH}/cmake/man/man1"
    install-man-dir 7 "${EXTRACT_PATH}/cmake/man/man7"

    install-bash-c cmake "${EXTRACT_PATH}/cmake/share/bash-completion/completions/cmake"
    install-bash-c cpack "${EXTRACT_PATH}/cmake/share/bash-completion/completions/cpack"
    install-bash-c ctest "${EXTRACT_PATH}/cmake/share/bash-completion/completions/ctest"
    cp -prv "${EXTRACT_PATH}/cmake/share/cmake-"* "${BUILD_PATH}/share/"

    install-bin "${EXTRACT_PATH}/tokei/tokei"

    install-bin "${EXTRACT_PATH}/dnslookup/dnslookup"

    mkdir -p "${BUILD_PATH}/share/ssl"
    wget -O "${BUILD_PATH}/share/ssl/cacert.pem" "https://curl.se/ca/cacert.pem"

    install-bin "${EXTRACT_PATH}/neofetch/neofetch"
    install-man 1 "${EXTRACT_PATH}/neofetch/neofetch.1"

    install-bin "${EXTRACT_PATH}/shfmt/shfmt"

    install-bin "${EXTRACT_PATH}/shellcheck/shellcheck"

    install-bin "${EXTRACT_PATH}/dasel/dasel"

    "${EXTRACT_PATH}/batscore/install.sh" "${BUILD_PATH}"

    if [[ "${ARCH}" == "x64" ]]; then
        install-all "${EXTRACT_PATH}/zstd"

        install-bin "${EXTRACT_PATH}/lshw/lshw"
        install-man 1 "${EXTRACT_PATH}/lshw/lshw.1"
        cp -prv "${EXTRACT_PATH}/lshw/hwdata" "${BUILD_PATH}/share/hwdata"
        install-all "${EXTRACT_PATH}/socat"
        install-all "${EXTRACT_PATH}/sockperf"
        install-all "${EXTRACT_PATH}/iperf"
    fi

    cp versions "${BUILD_PATH}/versions"
    cp versions "${BUILD_PATH}/versions.${ARCH}"
    cp versions "versions.${ARCH}"

}

gen-completions() {
    if [[ -x "${BUILD_PATH}/bin/rclone" ]]; then
        "${BUILD_PATH}/bin/rclone" completion bash >/tmp/rclone.bash
        "${BUILD_PATH}/bin/rclone" completion zsh >/tmp/_rclone
        install-bash-c rclone "/tmp/rclone.bash"
        install-zsh-c rclone "/tmp/_rclone"
    fi

    if [[ -x "${BUILD_PATH}/bin/pandoc" ]]; then
        "${BUILD_PATH}/bin/pandoc" --bash-completion >/tmp/pandoc.bash
        install-bash-c pandoc "/tmp/pandoc.bash"
    fi

    if [[ -x "${BUILD_PATH}/bin/gh" ]]; then
        ${BUILD_PATH}/bin/gh completion -s bash >"/tmp/gh.bash"
        ${BUILD_PATH}/bin/gh completion -s zsh >"/tmp/_gh"
        install-bash-c gh "/tmp/gh.bash"
        install-zsh-c gh "/tmp/_gh"
    fi

    if [[ -x "${BUILD_PATH}/bin/dasel" ]]; then
        ${BUILD_PATH}/bin/dasel completion bash >"/tmp/dasel.bash"
        ${BUILD_PATH}/bin/dasel completion zsh >"/tmp/_dasel"
        install-bash-c dasel "/tmp/dasel.bash"
        install-zsh-c dasel "/tmp/_dasel"
    fi
}

main() {
    download
    install
    gen-completions

    tar -cvzf "linux-${ARCH}.tar.gz" build
    tar -cvf "linux-${ARCH}.tar" build
    zstd -19 -T4 "linux-${ARCH}.tar"
    gh release upload bin "linux-${ARCH}.tar.gz" "linux-${ARCH}.tar.zst" --clobber
    if [[ "${ARCH}" == "x64" ]]; then
        gh release upload bin "versions" --clobber
    fi
    gh release upload bin "versions.${ARCH}" --clobber
}

wget -qO "versions.old" "https://github.com/Pusnow/bin/releases/download/bin/versions.${ARCH}" || true
if diff -q "versions.old" "versions" &>/dev/null; then
    echo "Skipping upgrade..."
else
    main
fi
