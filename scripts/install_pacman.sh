#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$DOTFILES_DIR/scripts/lib/common.sh"

PACMAN_PACKAGES=(
    tmux
    zsh
    starship
    zsh-autosuggestions
    zsh-syntax-highlighting
    yazi
    ffmpegthumbnailer
    unarchiver
    eza
    bat
    ncdu
    zoxide
    fzf
    git
    neovim
    python
    python-pip
    shellcheck
    tealdeer
    ripgrep
    fd
    poppler
    btop
    curl
    wget
    unzip
    jq
    lazygit
)

main() {
    log_info "Updating Arch Linux packages."
    sudo pacman -Syu --noconfirm

    log_info "Installing Arch Linux packages."
    sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"

    log_success "All pacman packages installed successfully."
}

main "$@"
