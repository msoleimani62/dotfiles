#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export DOTFILES_ENV='generic'

source "$DOTFILES_DIR/scripts/lib/common.sh"

main() {
    local package_manager

    log_section "Generic Linux environment"

    package_manager="$(detect_package_manager)"

    log_info "Detected package manager: $package_manager"

    case "$package_manager" in
        apt)
            bash "$DOTFILES_DIR/scripts/install_apt.sh"
            ;;
        dnf)
            bash "$DOTFILES_DIR/scripts/install_dnf.sh"
            ;;
        zypper)
            bash "$DOTFILES_DIR/scripts/install_zypper.sh"
            ;;
        pacman)
            bash "$DOTFILES_DIR/scripts/install_pacman.sh"
            ;;
        none)
            die "No supported package manager found."
            ;;
        *)
            die "Unsupported package manager: $package_manager"
            ;;
    esac

    log_info "Installing user binaries."
    bash "$DOTFILES_DIR/scripts/install_binaries.sh"

    log_info "Linking configuration files."
    bash "$DOTFILES_DIR/scripts/link_configs.sh"

    bash "$DOTFILES_DIR/scripts/finalize.sh"

    log_success "Generic Linux environment installation complete."
}

main "$@"
