# Generic Linux environment

ZSH_ENV_FILE="${${(%):-%N}:A}"
ZSH_ENV_DIR="${ZSH_ENV_FILE:h}"

source "$ZSH_ENV_DIR/../modules/loader.zsh" || return 1

unset ZSH_ENV_FILE ZSH_ENV_DIR

if command -v apt >/dev/null 2>&1; then
    alias update="sudo apt update && sudo apt upgrade"
elif command -v dnf >/dev/null 2>&1; then
    alias update="sudo dnf upgrade"
elif command -v zypper >/dev/null 2>&1; then
    alias update="sudo zypper update"
elif command -v pacman >/dev/null 2>&1; then
    alias update="sudo pacman -Syu"
fi
