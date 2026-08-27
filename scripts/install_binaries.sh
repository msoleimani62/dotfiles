#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_DIR/scripts/lib/common.sh"

BIN_DIR="${HOME}/.local/bin"
ARCH="$(detect_arch)"
TMP_DIRS=()

mkdir -p -- "$BIN_DIR"

cleanup() {
    local tmp_dir

    for tmp_dir in "${TMP_DIRS[@]}"; do
        [[ -n "$tmp_dir" && -d "$tmp_dir" ]] || continue
        rm -rf -- "$tmp_dir"
    done
}

trap cleanup EXIT

require_commands curl tar unzip jq mktemp

get_latest_version() {
    local repo="$1"

    curl -fsSL \
        --retry 3 \
        --retry-delay 2 \
        --connect-timeout 15 \
        --max-time 60 \
        -H 'Accept: application/vnd.github+json' \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "https://api.github.com/repos/$repo/releases/latest" |
        jq -er '.tag_name | ltrimstr("v")'
}

download_file() {
    local url="$1"
    local output="$2"

    curl -fL \
        --retry 3 \
        --retry-delay 2 \
        --connect-timeout 15 \
        --max-time 300 \
        --output "$output" \
        "$url"
}

verify_binary() {
    local binary="$1"

    [[ -x "$binary" ]] ||
        die "Installed binary is missing or not executable: $binary"

    "$binary" --version >/dev/null 2>&1 ||
        die "Installed binary failed verification: $binary"
}

install_yazi() {
    local version
    local archive
    local tmp_dir
    local extracted_dir
    local binary_arch

    version="$(get_latest_version 'sxyazi/yazi')" ||
        die "Unable to determine yazi version."

    case "$ARCH" in
        x86_64)
            binary_arch='x86_64'
            ;;
        aarch64)
            binary_arch='aarch64'
            ;;
        *)
            log_warn "Skipping yazi: unsupported architecture $ARCH."
            return 0
            ;;
    esac

    if [[ -x "$BIN_DIR/yazi" && -x "$BIN_DIR/ya" ]]; then
        if "$BIN_DIR/yazi" --version 2>/dev/null | grep -q "$version"; then
            log_success "yazi $version is already installed."
            return 0
        fi
    fi

    tmp_dir="$(mktemp -d)"
    TMP_DIRS+=("$tmp_dir")
    archive="$tmp_dir/yazi.zip"

    download_file \
        "https://github.com/sxyazi/yazi/releases/download/v${version}/yazi-${binary_arch}-unknown-linux-gnu.zip" \
        "$archive"

    unzip -q "$archive" -d "$tmp_dir"

    extracted_dir="$(
        find "$tmp_dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type d \
            -name 'yazi-*' \
            -print -quit
    )"

    [[ -n "$extracted_dir" ]] ||
        die "Unable to locate extracted yazi directory."

    atomic_install_file "$extracted_dir/yazi" "$BIN_DIR/yazi"
    atomic_install_file "$extracted_dir/ya" "$BIN_DIR/ya"

    verify_binary "$BIN_DIR/yazi"
    verify_binary "$BIN_DIR/ya"

    log_success "yazi $version installed."
}

install_lazygit() {
    local version
    local archive
    local tmp_dir
    local arch_label

    version="$(get_latest_version 'jesseduffield/lazygit')" ||
        die "Unable to determine lazygit version."

    case "$ARCH" in
        x86_64)
            arch_label='x86_64'
            ;;
        aarch64)
            arch_label='arm64'
            ;;
        *)
            log_warn "Skipping lazygit: unsupported architecture $ARCH."
            return 0
            ;;
    esac

    if [[ -x "$BIN_DIR/lazygit" ]] &&
        "$BIN_DIR/lazygit" --version 2>/dev/null | grep -q "$version"; then
        log_success "lazygit $version is already installed."
        return 0
    fi

    tmp_dir="$(mktemp -d)"
    TMP_DIRS+=("$tmp_dir")
    archive="$tmp_dir/lazygit.tar.gz"

    download_file \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch_label}.tar.gz" \
        "$archive"

    tar -xzf "$archive" -C "$tmp_dir" lazygit

    atomic_install_file "$tmp_dir/lazygit" "$BIN_DIR/lazygit"
    verify_binary "$BIN_DIR/lazygit"

    log_success "lazygit $version installed."
}

install_zoxide() {
    local version
    local archive
    local tmp_dir
    local arch_label

    version="$(get_latest_version 'ajeetdsouza/zoxide')" ||
        die "Unable to determine zoxide version."

    case "$ARCH" in
        x86_64)
            arch_label='x86_64-unknown-linux-musl'
            ;;
        aarch64)
            arch_label='aarch64-unknown-linux-musl'
            ;;
        *)
            log_warn "Skipping zoxide: unsupported architecture $ARCH."
            return 0
            ;;
    esac

    if [[ -x "$BIN_DIR/zoxide" ]] &&
        "$BIN_DIR/zoxide" --version 2>/dev/null | grep -q "$version"; then
        log_success "zoxide $version is already installed."
        return 0
    fi

    tmp_dir="$(mktemp -d)"
    TMP_DIRS+=("$tmp_dir")
    archive="$tmp_dir/zoxide.tar.gz"

    download_file \
        "https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-${arch_label}.tar.gz" \
        "$archive"

    tar -xzf "$archive" -C "$tmp_dir"

    atomic_install_file "$tmp_dir/zoxide" "$BIN_DIR/zoxide"
    verify_binary "$BIN_DIR/zoxide"

    log_success "zoxide $version installed."
}

install_fzf() {
    local version
    local archive
    local tmp_dir
    local arch_label

    version="$(get_latest_version 'junegunn/fzf')" ||
        die "Unable to determine fzf version."

    case "$ARCH" in
        x86_64)
            arch_label='amd64'
            ;;
        aarch64)
            arch_label='arm64'
            ;;
        *)
            log_warn "Skipping fzf: unsupported architecture $ARCH."
            return 0
            ;;
    esac

    if [[ -x "$BIN_DIR/fzf" ]] &&
        "$BIN_DIR/fzf" --version 2>/dev/null | grep -q "^${version}"; then
        log_success "fzf $version is already installed."
        return 0
    fi

    tmp_dir="$(mktemp -d)"
    TMP_DIRS+=("$tmp_dir")
    archive="$tmp_dir/fzf.tar.gz"

    download_file \
        "https://github.com/junegunn/fzf/releases/download/v${version}/fzf-${version}-linux_${arch_label}.tar.gz" \
        "$archive"

    tar -xzf "$archive" -C "$tmp_dir"

    atomic_install_file "$tmp_dir/fzf" "$BIN_DIR/fzf"
    verify_binary "$BIN_DIR/fzf"

    log_success "fzf $version installed."
}

install_starship() {
    local version
    local archive
    local tmp_dir
    local arch_label

    version="$(get_latest_version 'starship/starship')" ||
        die "Unable to determine starship version."

    case "$ARCH" in
        x86_64)
            arch_label='x86_64'
            ;;
        aarch64)
            arch_label='aarch64'
            ;;
        *)
            log_warn "Skipping starship: unsupported architecture $ARCH."
            return 0
            ;;
    esac

    if [[ -x "$BIN_DIR/starship" ]] &&
        "$BIN_DIR/starship" --version 2>/dev/null | grep -q "^starship ${version}"; then
        log_success "starship $version is already installed."
        return 0
    fi

    tmp_dir="$(mktemp -d)"
    TMP_DIRS+=("$tmp_dir")
    archive="$tmp_dir/starship.tar.gz"

    download_file \
        "https://github.com/starship/starship/releases/download/v${version}/starship-${arch_label}-unknown-linux-musl.tar.gz" \
        "$archive"

    tar -xzf "$archive" -C "$tmp_dir"

    atomic_install_file "$tmp_dir/starship" "$BIN_DIR/starship"
    verify_binary "$BIN_DIR/starship"

    log_success "starship $version installed."
}

main() {
    log_section "Installing user binaries"

    log_info "Detected architecture: $ARCH"

    install_yazi
    install_lazygit
    install_zoxide
    install_fzf
    install_starship

    log_success "User binaries installed successfully."
    log_info "Binary directory: $BIN_DIR"
}

main "$@"
