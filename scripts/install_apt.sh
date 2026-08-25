#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$DOTFILES_DIR/scripts/lib/common.sh"

IS_PROOT_KALI="${IS_PROOT_KALI:-}"
KALI_MIRROR="${KALI_MIRROR:-https://http.kali.org/kali}"

APT_PACKAGES=(
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
    shellcheck
    tealdeer
    ripgrep
    fd-find
    poppler-utils
    htop
    curl
    wget
    unzip
    jq
)

detect_proot_kali() {
    if [ -n "$IS_PROOT_KALI" ]; then
        return 0
    fi

    if [ -t 0 ] && grep -qi 'kali' /etc/os-release 2>/dev/null; then
        printf '%s' 'Running inside Kali NetHunter proot? Apply Kali mirror and proot dpkg fixes? [y/N]: '
        read -r answer

        case "$answer" in
            y|Y|yes|YES|Yes)
                IS_PROOT_KALI='yes'
                ;;
            *)
                IS_PROOT_KALI='no'
                ;;
        esac
    else
        IS_PROOT_KALI='no'
    fi

    export IS_PROOT_KALI
}

backup_file_if_exists() {
    local path="$1"

    if [ -e "$path" ] || [ -L "$path" ]; then
        backup_path "$path"
    fi
}

setup_mirror() {
    local sources_file="/etc/apt/sources.list"

    log_info "Configuring Kali package mirror."

    backup_file_if_exists "$sources_file"

    printf 'deb %s kali-rolling main contrib non-free non-free-firmware\n' "$KALI_MIRROR" |
        sudo tee "$sources_file" >/dev/null

    log_success "Kali mirror configured: $KALI_MIRROR"
}

fix_proot_dpkg() {
    log_info "Applying Kali NetHunter proot dpkg compatibility fixes."

    if [ ! -f /usr/sbin/policy-rc.d ]; then
        sudo tee /usr/sbin/policy-rc.d >/dev/null <<'EOF_POLICY'
#!/bin/sh
exit 101
EOF_POLICY
        sudo chmod +x /usr/sbin/policy-rc.d
        log_success "Created policy-rc.d."
    fi

    if [ -x /usr/bin/systemd-sysusers ] && [ ! -e /usr/bin/systemd-sysusers.real ]; then
        sudo cp -a /usr/bin/systemd-sysusers /usr/bin/systemd-sysusers.real
        sudo tee /usr/bin/systemd-sysusers >/dev/null <<'EOF_SYSUSERS'
#!/bin/sh
exit 0
EOF_SYSUSERS
        sudo chmod +x /usr/bin/systemd-sysusers
        log_success "Created systemd-sysusers wrapper."
    fi

    if [ -x /usr/bin/systemd-tmpfiles ] && [ ! -e /usr/bin/systemd-tmpfiles.real ]; then
        sudo cp -a /usr/bin/systemd-tmpfiles /usr/bin/systemd-tmpfiles.real
        sudo tee /usr/bin/systemd-tmpfiles >/dev/null <<'EOF_TMPFILES'
#!/bin/sh
exit 0
EOF_TMPFILES
        sudo chmod +x /usr/bin/systemd-tmpfiles
        log_success "Created systemd-tmpfiles wrapper."
    fi
}

install_apt_packages() {
    log_info "Updating apt package lists."
    sudo apt update

    log_info "Installing apt packages."
    sudo apt install -y "${APT_PACKAGES[@]}"

    if command -v batcat >/dev/null 2>&1; then
        sudo ln -sfn /usr/bin/batcat /usr/local/bin/bat
    fi

    if command -v fdfind >/dev/null 2>&1; then
        sudo ln -sfn /usr/bin/fdfind /usr/local/bin/fd
    fi

    log_success "All apt packages installed successfully."
}

main() {
    detect_proot_kali

    if [ "$IS_PROOT_KALI" = 'yes' ]; then
        setup_mirror
        fix_proot_dpkg
    else
        log_info "Skipping Kali NetHunter proot-specific fixes."
    fi

    install_apt_packages
}

main "$@"
