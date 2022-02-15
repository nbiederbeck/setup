#!/bin/bash
fonts=(
noto-fonts-emoji
otf-latin-modern
otf-latinmodern-math
ttf-fira-code
ttf-ibm-plex
adobe-source-code-pro-fonts
adobe-source-sans-fonts
adobe-source-serif-fonts
)

yay -Syu --needed "${fonts[@]}"
