#!/bin/bash
packages=()
export TEXLIVE_INSTALL_PREFIX=${HOME}/.local/texlive

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
Install TexLive
Install Conda (+Mamba)
Install Fonts

Setup Configurations
"
}

usage="Set up new computers.

Args:
    -h | --help
        Show this help.
"

case $1 in
    -h|--help) msg "${usage}" && exit ;;
    *) err "No command provided." ;;
esac

todo
