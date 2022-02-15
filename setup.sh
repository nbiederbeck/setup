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

packages=(
    zsh
    exa
    ripgrep
    fd
    alacritty
    tmux
    htop
    neovim
    polybar
)

install_yay () {
    sudo pacman -Syu --needed git base-devel
    cd "$(mktemp -d)" || exit 1
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin || exit 1
    makepkg -si
    yay -Y --devel --combinedupgrade --batchinstall --nocleanafter --save
}

mirrorrank () {
    yay -S --needed pacman-contrib curl
    curl -s "https://archlinux.org/mirrorlist/?country=DE&protocol=https&use_mirror_status=on" | sed -e 's/^#Server/Server/' -e '/^#/d' | rankmirrors -n 5 - | sudo tee /etc/pacman.d/mirrorlist
}

install_packages () {
    command -v yay || install_yay
    mirrorrank
    yay -Syyu --needed "${packages[@]}"
    setup_neovim
}

setup_neovim () {
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
	           https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    command -v mamba || install_conda
    mamba env create -f ~/.config/nvim/environment-nvim.yml
    nvim +'PlugInstall|UpdateRemotePlugins|qa'
}

install_texlive () {
    TEXLIVE_PREFIX="${HOME}/.local/texlive"
    cd "$(mktemp -d)" || exit 1
    curl -L http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz | tar xz

    cd install-tl-* || exit 1

    # empty profile uses defaults
    touch texlive.profile

    TEXLIVE_INSTALL_PREFIX=${TEXLIVE_PREFIX} \
    TEXLIVE_INSTALL_NO_RESUME=1 \
    TEXLIVE_INSTALL_NO_WELCOME=1 \
    TEXLIVE_INSTALL_TEXMFHOME=~/.texmf \
        ./install-tl -profile texlive.profile

    cd "$(find "${TEXLIVE_PREFIX}" -name '20*' | sort | head -1)/bin/x86_64-linux" || exit 1
    ./tlmgr option autobackup -- -1
    ./tlmgr option repository http://mirror.ctan.org/systems/texlive/tlnet

    git clone -q --depth 1 https://github.com/maxnoe/tudobeamertheme "$(kpsewhich --var-value TEXMFHOME)/tex/latex/tudobeamertheme"
    git clone -q --depth 1 https://github.com/maxnoe/tudothesis "$(kpsewhich --var-value TEXMFHOME)/tex/latex/tudothesis"

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

install_fonts () {
    bash ./fonts.sh
}

case $1 in
    -h|--help) msg "${usage}" && exit ;;
    conda) install_conda ;;
    texlive) install_texlive ;;
    packages) install_packages ;;
    *) err "No command provided." ;;
esac

todo
