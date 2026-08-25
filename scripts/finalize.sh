#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$DOTFILES_DIR/scripts/lib/common.sh"

configure_shell() {
    local zsh_path
    local login_shell

    zsh_path="$(command -v zsh || true)"

    if [ -z "$zsh_path" ]; then
        log_warn "zsh is not installed; skipping default shell configuration."
        return 0
    fi

    login_shell="$(get_login_shell)"

    if [ "$login_shell" = "$zsh_path" ]; then
        log_success "Default login shell is already zsh."
        return 0
    fi

    if chsh -s "$zsh_path"; then
        log_success "Default login shell changed to zsh."
    else
        log_warn "Unable to change the default shell automatically."
        log_warn "Run manually: chsh -s $zsh_path"
    fi
}

update_yazi_plugins() {
    local ya_bin

    ya_bin="$(command -v ya || true)"

    if [ -z "$ya_bin" ]; then
        log_warn "ya was not found; skipping yazi plugin update."
        return 0
    fi

    log_info "Updating yazi plugins."

    if "$ya_bin" pkg upgrade; then
        log_success "Yazi plugins updated."
    else
        log_warn "Yazi plugin update failed."
    fi
}

update_tldr() {
    if ! command -v tldr >/dev/null 2>&1; then
        return 0
    fi

    log_info "Updating tldr cache."

    if tldr --update; then
        log_success "tldr cache updated."
    else
        log_warn "tldr cache update failed."
    fi
}

main() {
    log_section "Final setup"

    configure_shell
    update_yazi_plugins
    update_tldr

    log_success "Final setup completed."
    log_info "Restart your terminal or run: source ~/.zshrc"
}

main "$@"
