#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$DOTFILES_DIR/scripts/lib/common.sh"

ZYPPER_PACKAGES=(
    tmux
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
    bat
    eza
    ncdu
    git
    neovim
    python3
    python3-pip
    ShellCheck
    tealdeer
    ripgrep
    fd
    poppler-tools
    htop
    curl
    wget
    unzip
    jq
)

main() {
    log_info "Installing openSUSE packages."
    sudo zypper --non-interactive install "${ZYPPER_PACKAGES[@]}"

    log_success "All zypper packages installed successfully."
}

main "$@"
