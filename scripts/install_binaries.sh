#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$DOTFILES_DIR/scripts/lib/common.sh"

BIN_DIR="${HOME}/.local/bin"
ARCH=""
TMP_DIRS=()

cleanup() {
    local tmp_dir

    for tmp_dir in "${TMP_DIRS[@]}"; do
        [[ -n "$tmp_dir" && -d "$tmp_dir" ]] || continue
        rm -rf -- "$tmp_dir"
    done
}

github_latest_version() {
    local repo="$1"

    curl -fsSL \
        --retry 3 \
        --retry-delay 2 \
        --connect-timeout 15 \
        --max-time 60 \
        -H 'Accept: application/vnd.github+json' \
        -H 'X-GitHub-Api-Version: 2022-11-28' \
        "https://api.github.com/repos/${repo}/releases/latest" |
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

create_tmp_dir() {
    local tmp_dir

    tmp_dir="$(mktemp -d)" ||
        die "Unable to create temporary directory."

    TMP_DIRS+=("$tmp_dir")
    CREATED_TMP_DIR="$tmp_dir"
}

extract_archive() {
    local archive="$1"
    local destination="$2"

    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$destination"
            ;;
        *.zip)
            unzip -q "$archive" -d "$destination"
            ;;
        *)
            die "Unsupported archive format: $archive"
            ;;
    esac
}

find_binary() {
    local root="$1"
    local name="$2"
    local candidate

    candidate="$(
        find "$root" \
            -type f \
            -name "$name" \
            -print -quit
    )"

    [[ -n "$candidate" ]] ||
        die "Unable to locate binary '$name' after extraction."

    printf '%s\n' "$candidate"
}

install_downloaded_binary() {
    local source="$1"
    local destination="$2"

    [[ -f "$source" ]] ||
        die "Binary source does not exist: $source"

    atomic_install_file "$source" "$destination" 755
}

binary_version() {
    local binary="$1"

    "$binary" --version 2>/dev/null
}

is_current_version() {
    local binary="$1"
    local expected="$2"
    local output

    [[ -x "$binary" ]] || return 1

    output="$(binary_version "$binary")" || return 1

    grep -Fq -- "$expected" <<< "$output"
}

install_yazi() {
    local version
    local binary_arch
    local tmp_dir
    local archive
    local extract_dir
    local yazi_binary
    local ya_binary

    version="$(github_latest_version 'sxyazi/yazi')" ||
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

    if is_current_version "$BIN_DIR/yazi" "$version"; then
        log_success "yazi $version is already installed."
        return 0
    fi

    create_tmp_dir
    tmp_dir="$CREATED_TMP_DIR"
    archive="$tmp_dir/yazi.zip"
    extract_dir="$tmp_dir/extracted"

    mkdir -p -- "$extract_dir"

    download_file \
        "https://github.com/sxyazi/yazi/releases/download/v${version}/yazi-${binary_arch}-unknown-linux-gnu.zip" \
        "$archive"

    extract_archive "$archive" "$extract_dir"

    yazi_binary="$(find_binary "$extract_dir" 'yazi')"
    ya_binary="$(find_binary "$extract_dir" 'ya')"

    install_downloaded_binary "$yazi_binary" "$BIN_DIR/yazi"
    install_downloaded_binary "$ya_binary" "$BIN_DIR/ya"

    is_current_version "$BIN_DIR/yazi" "$version" ||
        die "Installed yazi failed version verification."

    log_success "yazi $version installed."
}

install_lazygit() {
    local version
    local arch_label
    local tmp_dir
    local archive
    local extract_dir
    local binary

    version="$(github_latest_version 'jesseduffield/lazygit')" ||
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

    if is_current_version "$BIN_DIR/lazygit" "$version"; then
        log_success "lazygit $version is already installed."
        return 0
    fi

    create_tmp_dir
    tmp_dir="$CREATED_TMP_DIR"
    archive="$tmp_dir/lazygit.tar.gz"
    extract_dir="$tmp_dir/extracted"

    mkdir -p -- "$extract_dir"

    download_file \
        "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch_label}.tar.gz" \
        "$archive"

    extract_archive "$archive" "$extract_dir"

    binary="$(find_binary "$extract_dir" 'lazygit')"

    install_downloaded_binary "$binary" "$BIN_DIR/lazygit"

    is_current_version "$BIN_DIR/lazygit" "$version" ||
        die "Installed lazygit failed version verification."

    log_success "lazygit $version installed."
}

install_zoxide() {
    local version
    local arch_label
    local tmp_dir
    local archive
    local extract_dir
    local binary

    version="$(github_latest_version 'ajeetdsouza/zoxide')" ||
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

    if is_current_version "$BIN_DIR/zoxide" "$version"; then
        log_success "zoxide $version is already installed."
        return 0
    fi

    create_tmp_dir
    tmp_dir="$CREATED_TMP_DIR"
    archive="$tmp_dir/zoxide.tar.gz"
    extract_dir="$tmp_dir/extracted"

    mkdir -p -- "$extract_dir"

    download_file \
        "https://github.com/ajeetdsouza/zoxide/releases/download/v${version}/zoxide-${version}-${arch_label}.tar.gz" \
        "$archive"

    extract_archive "$archive" "$extract_dir"

    binary="$(find_binary "$extract_dir" 'zoxide')"

    install_downloaded_binary "$binary" "$BIN_DIR/zoxide"

    is_current_version "$BIN_DIR/zoxide" "$version" ||
        die "Installed zoxide failed version verification."

    log_success "zoxide $version installed."
}

install_fzf() {
    local version
    local arch_label
    local tmp_dir
    local archive
    local extract_dir
    local binary

    version="$(github_latest_version 'junegunn/fzf')" ||
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

    if is_current_version "$BIN_DIR/fzf" "$version"; then
        log_success "fzf $version is already installed."
        return 0
    fi

    create_tmp_dir
    tmp_dir="$CREATED_TMP_DIR"
    archive="$tmp_dir/fzf.tar.gz"
    extract_dir="$tmp_dir/extracted"

    mkdir -p -- "$extract_dir"

    download_file \
        "https://github.com/junegunn/fzf/releases/download/v${version}/fzf-${version}-linux_${arch_label}.tar.gz" \
        "$archive"

    extract_archive "$archive" "$extract_dir"

    binary="$(find_binary "$extract_dir" 'fzf')"

    install_downloaded_binary "$binary" "$BIN_DIR/fzf"

    is_current_version "$BIN_DIR/fzf" "$version" ||
        die "Installed fzf failed version verification."

    log_success "fzf $version installed."
}

install_starship() {
    local version
    local arch_label
    local tmp_dir
    local archive
    local extract_dir
    local binary

    version="$(github_latest_version 'starship/starship')" ||
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

    if is_current_version "$BIN_DIR/starship" "$version"; then
        log_success "starship $version is already installed."
        return 0
    fi

    create_tmp_dir
    tmp_dir="$CREATED_TMP_DIR"
    archive="$tmp_dir/starship.tar.gz"
    extract_dir="$tmp_dir/extracted"

    mkdir -p -- "$extract_dir"

    download_file \
        "https://github.com/starship/starship/releases/download/v${version}/starship-${arch_label}-unknown-linux-musl.tar.gz" \
        "$archive"

    extract_archive "$archive" "$extract_dir"

    binary="$(find_binary "$extract_dir" 'starship')"

    install_downloaded_binary "$binary" "$BIN_DIR/starship"

    is_current_version "$BIN_DIR/starship" "$version" ||
        die "Installed starship failed version verification."

    log_success "starship $version installed."
}

main() {
    log_section "Installing user binaries"

    require_commands curl jq tar unzip mktemp

    mkdir -p -- "$BIN_DIR"

    ARCH="$(detect_arch)"

    trap cleanup EXIT

    log_info "Detected architecture: $ARCH"
    log_info "Binary directory: $BIN_DIR"

    install_yazi
    install_lazygit
    install_zoxide
    install_fzf
    install_starship

    log_success "User binaries installed successfully."
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
