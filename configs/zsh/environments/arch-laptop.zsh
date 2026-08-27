# Arch Linux laptop environment

ZSH_ENV_FILE="${${(%):-%N}:A}"
ZSH_ENV_DIR="${ZSH_ENV_FILE:h}"

source "$ZSH_ENV_DIR/../modules/loader.zsh" || return 1

unset ZSH_ENV_FILE ZSH_ENV_DIR

alias update="sudo pacman -Syu"
