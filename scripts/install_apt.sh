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

POLICY_RC_D="/usr/sbin/policy-rc.d"
POLICY_RC_BACKUP=""
POLICY_RC_CREATED=0

cleanup_policy_rc_d() {
    if [[ -n "$POLICY_RC_BACKUP" && -e "$POLICY_RC_BACKUP" ]]; then
        if sudo test -e "$POLICY_RC_D" || sudo test -L "$POLICY_RC_D"; then
            sudo rm -f -- "$POLICY_RC_D"
        fi

        sudo mv -- "$POLICY_RC_BACKUP" "$POLICY_RC_D"
        POLICY_RC_BACKUP=""

        log_success "Restored previous policy-rc.d."
    elif (( POLICY_RC_CREATED )); then
        if sudo test -e "$POLICY_RC_D" || sudo test -L "$POLICY_RC_D"; then
            sudo rm -f -- "$POLICY_RC_D"
        fi

        POLICY_RC_CREATED=0
        log_success "Removed temporary policy-rc.d."
    fi
}

detect_proot_kali() {
    if [[ -n "$IS_PROOT_KALI" ]]; then
        return 0
    fi

    if [[ ! -r /etc/os-release ]]; then
        IS_PROOT_KALI='no'
        export IS_PROOT_KALI
        return 0
    fi

    if ! grep -Eq '^[[:space:]]*(ID|ID_LIKE)=.*kali' /etc/os-release; then
        IS_PROOT_KALI='no'
        export IS_PROOT_KALI
        return 0
    fi

    if [[ -n "${TERMUX_VERSION:-}" ]] ||
        [[ -n "${PREFIX:-}" && "$PREFIX" == *termux* ]]; then
        IS_PROOT_KALI='yes'
        export IS_PROOT_KALI
        return 0
    fi

    if [[ -t 0 ]]; then
        printf '%s' 'Running inside Kali NetHunter proot? [y/N]: '
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

setup_mirror() {
    local sources_file="/etc/apt/sources.list"
    local expected_line
    local temp_file=""
    local backup_file=""
    local mode
    local owner
    local group

    expected_line="deb ${KALI_MIRROR} kali-rolling main contrib non-free non-free-firmware"

    if [[ -L "$sources_file" ]]; then
        die "Refusing to modify symlinked apt sources.list: $sources_file"
    fi

    if [[ -f "$sources_file" ]] &&
        grep -Fqx "$expected_line" "$sources_file"; then
        log_success "Kali mirror already configured."
        return 0
    fi

    log_warn "Updating Kali apt mirror configuration."

    sudo install -d -m 755 /etc/apt

    temp_file="$(mktemp)" ||
        die "Unable to create temporary apt sources file."

    cleanup_mirror() {
        rm -f -- "$temp_file" "$backup_file"
    }

    trap cleanup_mirror RETURN

    if [[ -f "$sources_file" ]]; then
        mode="$(sudo stat -c '%a' "$sources_file")" ||
            die "Unable to read sources.list permissions."

        owner="$(sudo stat -c '%u' "$sources_file")" ||
            die "Unable to read sources.list owner."

        group="$(sudo stat -c '%g' "$sources_file")" ||
            die "Unable to read sources.list group."

        backup_file="$(mktemp)" ||
            die "Unable to create apt sources backup."

        sudo cp -a -- "$sources_file" "$backup_file" ||
            die "Unable to create apt sources backup."

        awk '
            /^[[:space:]]*deb[[:space:]]/ {
                if ($0 ~ /^[[:space:]]*deb[[:space:]]+(https?:\/\/)?[^[:space:]]*kali[^[:space:]]*/) {
                    next
                }
            }

            { print }
        ' "$sources_file" >"$temp_file" ||
            die "Unable to prepare apt sources configuration."

        printf '%s\n' "$expected_line" >>"$temp_file"
    else
        mode=644
        owner=0
        group=0

        printf '%s\n' "$expected_line" >"$temp_file" ||
            die "Unable to prepare apt sources configuration."
    fi

    sudo chown "$owner:$group" "$temp_file" ||
        die "Unable to set apt sources ownership."

    sudo chmod "$mode" "$temp_file" ||
        die "Unable to set apt sources permissions."

    sudo install \
        -o "$owner" \
        -g "$group" \
        -m "$mode" \
        "$temp_file" \
        "$sources_file" ||
        die "Unable to install apt sources configuration."

    if ! sudo grep -Fqx "$expected_line" "$sources_file"; then
        log_error "Apt sources verification failed."

        if [[ -n "$backup_file" && -f "$backup_file" ]]; then
            sudo install \
                -o "$owner" \
                -g "$group" \
                -m "$mode" \
                "$backup_file" \
                "$sources_file" ||
                log_error "Apt sources rollback failed."
        fi

        die "Apt sources configuration was not applied safely."
    fi

    rm -f -- "$temp_file"
    temp_file=""

    rm -f -- "$backup_file"
    backup_file=""

    trap - RETURN

    log_success "Kali mirror configured: $KALI_MIRROR"
}

setup_policy_rc_d() {
    local timestamp

    if sudo test -e "$POLICY_RC_D" || sudo test -L "$POLICY_RC_D"; then
        timestamp="$(date +%Y%m%d-%H%M%S-%N)"
        POLICY_RC_BACKUP="${POLICY_RC_D}.dotfiles-backup.${timestamp}"

        sudo mv -- "$POLICY_RC_D" "$POLICY_RC_BACKUP"

        log_info "Temporarily moved existing policy-rc.d."
    else
        POLICY_RC_CREATED=1
    fi

    sudo tee "$POLICY_RC_D" >/dev/null <<'EOF_POLICY'
#!/bin/sh
# جلوگیری از اجرای سرویس‌ها هنگام نصب در محیط PRoot
# Prevent services from starting during installation inside PRoot
exit 101
EOF_POLICY

    sudo chmod 755 "$POLICY_RC_D"

    log_success "Temporary policy-rc.d installed."
}

install_apt_packages() {
    log_info "Updating apt package lists."
    sudo apt update

    log_info "Installing apt packages."
    sudo apt install -y "${APT_PACKAGES[@]}"

    if command -v batcat >/dev/null 2>&1 &&
        [[ ! -e /usr/local/bin/bat && ! -L /usr/local/bin/bat ]]; then
        sudo ln -s /usr/bin/batcat /usr/local/bin/bat
    fi

    if command -v fdfind >/dev/null 2>&1 &&
        [[ ! -e /usr/local/bin/fd && ! -L /usr/local/bin/fd ]]; then
        sudo ln -s /usr/bin/fdfind /usr/local/bin/fd
    fi

    log_success "All apt packages installed successfully."
}

main() {
    trap cleanup_policy_rc_d EXIT

    require_commands apt sudo grep mktemp

    detect_proot_kali

    if [[ "$IS_PROOT_KALI" == 'yes' ]]; then
        setup_mirror
        setup_policy_rc_d
    else
        log_info "Skipping Kali NetHunter proot-specific configuration."
    fi

    install_apt_packages
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
