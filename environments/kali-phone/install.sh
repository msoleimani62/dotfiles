#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export DOTFILES_ENV='kali'

source "$DOTFILES_DIR/scripts/lib/common.sh"

main() {
    log_section "Kali NetHunter phone environment"

    log_info "Installing system packages."
    bash "$DOTFILES_DIR/scripts/install_apt.sh"

    log_info "Installing user binaries."
    bash "$DOTFILES_DIR/scripts/install_binaries.sh"

    log_info "Linking configuration files."
    bash "$DOTFILES_DIR/scripts/link_configs.sh"

    bash "$DOTFILES_DIR/scripts/finalize.sh"

    log_success "Kali NetHunter environment installation complete."
}

main "$@"
