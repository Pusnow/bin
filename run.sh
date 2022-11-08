#!/bin/bash

set -ex

export BUILD_PATH=build
export EXTRACT_PATH=extract

strip-directory() {
    NE=$(find "${1}" -maxdepth 1 -mindepth 1 | wc -l | xargs || true)
    ND=$(find "${1}" -maxdepth 1 -mindepth 1 -type d | wc -l | xargs || true)

    if [[ "${NE}" == "1" ]] && [[ "${ND}" == "1" ]]; then
        DIR=$(find "${1}" -maxdepth 1 -mindepth 1)
        mv "${DIR}/"* "${1}"
        rm -r "${DIR}"
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
    unzip -d "${EXTRACT_PATH}/${1}" "${EXTRACT_PATH}/${1}.zip"
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
    cp -prv "${1}" "${BUILD_PATH}/share/bash_completion.d/"
}
install-zsh-c() {
    cp -prv "${1}" "${BUILD_PATH}/share/zsh_completion.d/"
}

download-install-man() {
    wget -qO "/tmp/${2}" "${3}"
    install-man "${1}" "/tmp/${2}"
}

download-install-bash-c() {
    wget -qO "/tmp/${1}" "${2}"
    install-bash-c "/tmp/${1}"
}

download-install-zsh-c() {
    wget -qO "/tmp/${1}" "${2}"
    install-zsh-c "/tmp/${1}"
}

if [[ ! -f versions ]]; then
    ./versions.sh >versions
fi

source versions

download() {
    mkdir -p "${EXTRACT_PATH}"
    download-untar fzf z "https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tar.gz"
    download-untar hexyl z "https://github.com/sharkdp/hexyl/releases/download/${HEXYL_VERSION}/hexyl-${HEXYL_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    download-untar delta z "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    download-untar nvim z "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz"
    download-unzip rclone "https://github.com/rclone/rclone/releases/download/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-amd64.zip"
    download-untar pandoc z "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz"
    download-untar bpftrace J "https://github.com/iovisor/bpftrace/releases/download/${BPFTRACE_VERSION}/binary_tools_man-bundle.tar.xz"
    download-file hadolint "https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64"
    download-file bazel "https://github.com/bazelbuild/bazelisk/releases/download/${BAZELISK_VERSION}/bazelisk-linux-amd64"
    download-file jq "https://github.com/stedolan/jq/releases/download/${JQ_VERSION}/jq-linux64"
    download-untar dust z "https://github.com/bootandy/dust/releases/download/${DUST_VERSION}/dust-${DUST_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
    download-untar fd z "https://github.com/sharkdp/fd/releases/download/${FD_VERSION}/fd-${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz"
    download-untar gh z "https://github.com/cli/cli/releases/download/${GH_VERSION}/gh_${GH_VERSION:1}_linux_amd64.tar.gz"
    download-untar rg z "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
    download-file kubectl "https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl"
    download-unzip ninja "https://github.com/ninja-build/ninja/releases/download/${NINJA_VERSION}/ninja-linux.zip"
    download-untar cmake z "https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz"
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
    download-install-bash-c fzf.bash "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/completion.bash"
    download-install-zsh-c _fzf "https://raw.githubusercontent.com/junegunn/fzf/${FZF_VERSION}/shell/completion.zsh"

    install-bin "${EXTRACT_PATH}/hexyl/hexyl"
    install-man 1 "${EXTRACT_PATH}/hexyl/hexyl.1"

    install-bin "${EXTRACT_PATH}/delta/delta"
    download-install-bash-c delta.bash "https://raw.githubusercontent.com/dandavison/delta/${DELTA_VERSION}/etc/completion/completion.bash"
    download-install-zsh-c _delta "https://raw.githubusercontent.com/dandavison/delta/${DELTA_VERSION}/etc/completion/completion.zsh"

    install-all "${EXTRACT_PATH}/nvim"

    install-bin "${EXTRACT_PATH}/rclone/rclone"
    install-man 1 "${EXTRACT_PATH}/rclone/rclone.1"

    install-all "${EXTRACT_PATH}/pandoc"

    install-all "${EXTRACT_PATH}/bpftrace"

    install-bin "${EXTRACT_PATH}/hadolint/hadolint"

    install-bin "${EXTRACT_PATH}/bazel/bazel"

    install-bin "${EXTRACT_PATH}/jq/jq"

    install-bin "${EXTRACT_PATH}/dust/dust"

    install-bin "${EXTRACT_PATH}/fd/fd"
    install-man 1 "${EXTRACT_PATH}/fd/fd.1"
    install-bash-c "${EXTRACT_PATH}/fd/autocomplete/fd.bash"
    install-zsh-c "${EXTRACT_PATH}/fd/autocomplete/_fd"

    install-all "${EXTRACT_PATH}/gh"

    install-bin "${EXTRACT_PATH}/rg/rg"
    install-bash-c "${EXTRACT_PATH}/rg/complete/rg.bash"
    install-zsh-c "${EXTRACT_PATH}/rg/complete/_rg"

    install-bin "${EXTRACT_PATH}/kubectl/kubectl"
    install-bin "${EXTRACT_PATH}/ninja/ninja"

    install-bin-dir "${EXTRACT_PATH}/cmake/bin"
    install-man-dir 1 "${EXTRACT_PATH}/cmake/man/man1"
    install-man-dir 7 "${EXTRACT_PATH}/cmake/man/man7"

    install-bash-c "${EXTRACT_PATH}/cmake/share/bash-completion/completions/cmake"
    mv "${BUILD_PATH}/share/bash_completion.d/cmake" "${BUILD_PATH}/share/bash_completion.d/cmake.bash"
    install-bash-c "${EXTRACT_PATH}/cmake/share/bash-completion/completions/cpack"
    mv "${BUILD_PATH}/share/bash_completion.d/cpack" "${BUILD_PATH}/share/bash_completion.d/cpack.bash"
    install-bash-c "${EXTRACT_PATH}/cmake/share/bash-completion/completions/ctest"
    mv "${BUILD_PATH}/share/bash_completion.d/ctest" "${BUILD_PATH}/share/bash_completion.d/ctest.bash"

    cp versions "${BUILD_PATH}/versions"

}

gen-completions() {
    "${BUILD_PATH}/bin/rclone" completion bash >/tmp/rclone.bash
    "${BUILD_PATH}/bin/rclone" completion zsh >/tmp/_rclone
    install-bash-c "/tmp/rclone.bash"
    install-zsh-c "/tmp/_rclone"

    "${BUILD_PATH}/bin/pandoc" --bash-completion >/tmp/pandoc.bash
    install-bash-c "/tmp/pandoc.bash"

    gh completion -s bash >"/tmp/gh.bash"
    gh completion -s zsh >"/tmp/_gh"
    install-bash-c "/tmp/gh.bash"
    install-zsh-c "/tmp/_gh"

    kubectl completion bash >"/tmp/kubectl.bash"
    kubectl completion zsh >"/tmp/_kubectl"
    install-bash-c "/tmp/kubectl.bash"
    install-zsh-c "/tmp/_kubectl"

}

download
install
gen-completions

tar -cvzf linux-x64.tar.gz build
tar -cvjf linux-x64.tar.bz2 build
tar -cvJf linux-x64.tar.xz build
gh release upload bin linux-x64.tar.gz linux-x64.tar.bz2 linux-x64.tar.xz --clobber
