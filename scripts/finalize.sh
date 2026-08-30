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
        log_warn "zsh is not installed; skipping shell configuration."
        return 0
    fi

    login_shell="$(get_login_shell)"

    if [ "$login_shell" = "$zsh_path" ]; then
        log_success "Default login shell is already zsh."
        return 0
    fi

    log_warn "Default login shell is not zsh."
    log_info "Run manually if desired: chsh -s $zsh_path"
}

main() {
    log_section "Final setup"
    configure_shell
    log_success "Final setup completed."
    log_info "Restart your terminal or run: source ~/.zshrc"
}

main "$@"
