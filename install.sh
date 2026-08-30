#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DOTFILES_DIR/scripts/lib/common.sh"

DOTFILES_VERSION="1.0.0"
VERSION_FILE="$HOME/.local/share/dotfiles/.version"

FORCE=0

for arg in "$@"; do
    case "$arg" in
        --force)
            FORCE=1
            ;;
        *)
            die "Unknown argument: $arg"
            ;;
    esac
done

write_version() {
    local version_dir
    local temp_file

    version_dir="$(dirname "$VERSION_FILE")"
    mkdir -p "$version_dir"

    temp_file="$(mktemp "$version_dir/.version.XXXXXX")"
    printf '%s\n' "$DOTFILES_VERSION" > "$temp_file"
    chmod 0644 "$temp_file"
    mv -f -- "$temp_file" "$VERSION_FILE"
}

main() {
    local env
    local installed_version=""

    log_section "dotfiles installer"

    if [[ -f "$VERSION_FILE" ]]; then
        installed_version="$(<"$VERSION_FILE")"

        log_info "Installed version: $installed_version"
        log_info "Target version: $DOTFILES_VERSION"

        if [[ "$installed_version" == "$DOTFILES_VERSION" && "$FORCE" -eq 0 ]]; then
            log_success "Already up to date: $installed_version"
            log_info "Run 'bash install.sh --force' to force a reinstall."
            exit 0
        fi

        if [[ "$FORCE" -eq 1 ]]; then
            log_info "Forced installation requested."
        else
            log_info "Version change detected; proceeding with installation."
        fi
    else
        log_info "No previous installation detected."
    fi

    env="$(detect_environment)"
    export DOTFILES_ENV="$env"

    log_info "Detected environment: ${BOLD}${DOTFILES_ENV}${RESET}"

    case "$DOTFILES_ENV" in
        kali)
            bash "$DOTFILES_DIR/environments/kali-phone/install.sh"
            ;;
        arch)
            bash "$DOTFILES_DIR/environments/arch-laptop/install.sh"
            ;;
        generic)
            bash "$DOTFILES_DIR/environments/generic-linux/install.sh"
            ;;
        *)
            die "Unsupported environment: $DOTFILES_ENV"
            ;;
    esac

    write_version

    log_section "Installation complete"
    log_success "Version $DOTFILES_VERSION installed successfully."
    log_info "Restart your terminal or run: source ~/.zshrc"
}

main "$@"
