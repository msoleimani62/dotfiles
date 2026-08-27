#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_DIR/scripts/lib/common.sh"

DOTFILES_ENV="${DOTFILES_ENV:-$(detect_environment)}"

link_yazi_configs() {
    # Link Yazi configuration files
    # اتصال فایل‌های تنظیمات Yazi

    make_link "$DOTFILES_DIR/configs/yazi/yazi.toml" "$HOME/.config/yazi/yazi.toml"
    make_link "$DOTFILES_DIR/configs/yazi/keymap.toml" "$HOME/.config/yazi/keymap.toml"
    make_link "$DOTFILES_DIR/configs/yazi/theme.toml" "$HOME/.config/yazi/theme.toml"
    make_link "$DOTFILES_DIR/configs/yazi/init.lua" "$HOME/.config/yazi/init.lua"
}

link_starship_config() {
    # Link Starship configuration
    # اتصال فایل تنظیمات Starship

    make_link "$DOTFILES_DIR/configs/starship.toml" "$HOME/.config/starship.toml"
}

remove_legacy_zsh_base() {
    local legacy_base
    local legacy_target

    legacy_base="$HOME/.zshrc.base"
    legacy_target="$DOTFILES_DIR/configs/zsh/.zshrc.base"

    if [[ -L "$legacy_base" ]]; then
        local current_target
        current_target="$(readlink "$legacy_base")"

        if [[ "$current_target" == "$legacy_target" ]]; then
            rm -f -- "$legacy_base"
            log_success "Removed obsolete Zsh base symlink: $legacy_base"
        fi

        unset current_target
    fi
}

link_zsh_config() {
    local zsh_config

    case "$DOTFILES_ENV" in
        arch)
            zsh_config="$DOTFILES_DIR/configs/zsh/environments/arch-laptop.zsh"
            ;;
        kali)
            zsh_config="$DOTFILES_DIR/configs/zsh/environments/kali-phone.zsh"
            ;;
        generic)
            zsh_config="$DOTFILES_DIR/configs/zsh/environments/generic.zsh"
            ;;
        *)
            die "Unsupported DOTFILES_ENV: $DOTFILES_ENV"
            ;;
    esac

    remove_legacy_zsh_base
    make_link "$zsh_config" "$HOME/.zshrc"
}

main() {
    log_section "Linking configuration files"

    case "$DOTFILES_ENV" in
        arch|kali|generic)
            ;;
        *)
            die "Unsupported DOTFILES_ENV: $DOTFILES_ENV"
            ;;
    esac

    link_yazi_configs
    link_starship_config
    link_zsh_config

    log_success "All configuration files linked."
    log_info "Private Zsh settings can be placed in ~/.zshrc.local."
}

main "$@"
