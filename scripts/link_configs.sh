#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$DOTFILES_DIR/scripts/lib/common.sh"

DOTFILES_ENV="${DOTFILES_ENV:-$(detect_environment)}"

link_configs() {
    log_section "Linking configuration files"

    case "$DOTFILES_ENV" in
        arch|kali|generic)
            ;;
        *)
            die "Unsupported DOTFILES_ENV: $DOTFILES_ENV"
            ;;
    esac

    make_link "$DOTFILES_DIR/configs/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
    make_link "$DOTFILES_DIR/configs/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
    make_link "$DOTFILES_DIR/configs/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
    make_link "$DOTFILES_DIR/configs/yazi/init.lua" "$HOME/.config/yazi/init.lua"

    make_link "$DOTFILES_DIR/configs/starship.toml" "$HOME/.config/starship.toml"

    make_link "$DOTFILES_DIR/configs/zsh/.zshrc.base" "$HOME/.zshrc.base"

    case "$DOTFILES_ENV" in
        arch)
            make_link "$DOTFILES_DIR/configs/zsh/.zshrc.arch-laptop" "$HOME/.zshrc"
            ;;
        kali)
            make_link "$DOTFILES_DIR/configs/zsh/.zshrc.kali-phone" "$HOME/.zshrc"
            ;;
        generic)
            make_link "$DOTFILES_DIR/configs/zsh/.zshrc.generic" "$HOME/.zshrc"
            ;;
    esac

    log_success "All configuration files linked."
    log_info "Private settings can be placed in ~/.zshrc.local."
}

main() {
    link_configs
}

main "$@"
