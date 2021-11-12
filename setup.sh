#!/bin/bash
msg () {
    echo -e "${*}" >/dev/stderr
}

warn () {
    msg "\e[1;33mWARN: ${*}\e[0m"
}

err () {
    msg "\e[1;31mERROR: ${*}\e[0m" && exit 1
}

todo () {
    msg "=== To Do ===
Install Packages
Install Fonts

Setup Configurations
"
}

usage="Set up new computers.

Args:
    -h | --help
        Show this help.
"

install_texlive () {
    TEXLIVE_PREFIX="${HOME}/.local/texlive"
    cd "$(mktemp -d)" || exit 1
    pwd
    curl -fsSL http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar xz

    cd install-tl-* || exit 1

    # empty profile uses defaults
    echo "selected_scheme scheme-basic" > texlive.profile

    TEXLIVE_INSTALL_PREFIX=${TEXLIVE_PREFIX} \
    TEXLIVE_INSTALL_NO_RESUME=1 \
    TEXLIVE_INSTALL_NO_WELCOME=1 \
    TEXLIVE_INSTALL_TEXMFHOME=~/.texmf \
        ./install-tl -profile texlive.profile

    cd "$(find "${TEXLIVE_PREFIX}" -name '20*' | sort | head -1)/bin/x86_64-linux" || exit 1
    ./tlmgr option autobackup -- -1
    ./tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet

    warn "Setup TexLive PATH"
}

install_conda () {
    cd "$(mktemp -d)" || exit 1
    conda_prefix="${HOME}/.local/miniconda3"
    filename="Miniconda3-latest-Linux-x86_64.sh"
    curl -fsSLO "https://repo.anaconda.com/miniconda/${filename}"
    bash "${filename}" -p "${conda_prefix}" -b -u
    . "${conda_prefix}/etc/profile.d/conda.sh"
    conda install -c conda-forge mamba --yes
}

case $1 in
    -h|--help) msg "${usage}" && exit ;;
    conda) install_conda ;;
    texlive) install_texlive ;;
    *) err "No command provided." ;;
esac

todo
