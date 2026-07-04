#!/usr/bin/env bash
# =============================================================================
# scripts/install_binaries.sh
# دانلود و نصب باینری‌های مستقیم از GitHub (مشترک بین همه محیط‌ها)
# Downloads and installs binaries directly from GitHub (shared across all environments)
# ابزارها / Tools: yazi, lazygit, zoxide, fzf, starship
# =============================================================================

set -e

BIN_DIR="${HOME}/.local/bin"
mkdir -p "$BIN_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }
log_error()   { echo -e "${RED}[✗]${RESET} $1"; }

# تشخیص معماری سیستم / Detect system architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64)  echo "x86_64" ;;
        aarch64) echo "aarch64" ;;
        armv7*)  echo "armv7" ;;
        *)       echo "unknown" ;;
    esac
}

ARCH=$(detect_arch)
log_info "معماری سیستم / System architecture: $ARCH"

# دریافت آخرین نسخه از GitHub / Get the latest version from GitHub
get_latest_version() {
    local repo="$1"
    curl -s "https://api.github.com/repos/${repo}/releases/latest" \
        | grep '"tag_name"' \
        | sed 's/.*"tag_name": *"v\?\([^"]*\)".*/\1/'
}

# =============================================================================
# نصب yazi / Install yazi
# =============================================================================
install_yazi() {
    log_info "نصب yazi... / Installing yazi..."
    local version
    version=$(get_latest_version "sxyazi/yazi")

    if [ -z "$version" ]; then
        log_warn "نمی‌توان نسخه‌ی yazi را دریافت کرد، از نسخه‌ی پیش‌فرض استفاده می‌شود"
        version="26.5.6"
    fi

    local current=""
    if command -v yazi &>/dev/null; then
        current=$(yazi --version 2>/dev/null | grep -oP 'Version: \K[0-9.]+' || echo "")
    fi

    if [ "$current" = "$version" ]; then
        log_success "yazi v$version از قبل نصب است، آپدیت لازم نیست"
        return
    fi

    log_info "دانلود yazi v$version برای $ARCH... / Downloading yazi v$version for $ARCH..."
    local url="https://github.com/sxyazi/yazi/releases/download/v${version}/yazi-${ARCH}-unknown-linux-gnu.zip"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    if curl -fsSL "$url" -o "$tmp_dir/yazi.zip"; then
        cd "$tmp_dir"
        unzip -q yazi.zip
        local extracted_dir
        extracted_dir=$(find . -maxdepth 1 -type d -name "yazi-*" | head -1)
        if [ -n "$extracted_dir" ]; then
            cp "$extracted_dir/yazi" "$BIN_DIR/"
            cp "$extracted_dir/ya" "$BIN_DIR/"
            chmod +x "$BIN_DIR/yazi" "$BIN_DIR/ya"
            log_success "yazi v$version نصب شد"
        else
            log_error "مشکل در extract کردن yazi"
        fi
        cd - > /dev/null
    else
        log_warn "دانلود باینری yazi ناموفق بود، از نسخه‌ی موجود استفاده می‌شود"
    fi

    rm -rf "$tmp_dir"
}

# =============================================================================
# نصب lazygit / Install lazygit
# =============================================================================
install_lazygit() {
    log_info "نصب lazygit... / Installing lazygit..."
    local version
    version=$(get_latest_version "jesseduffield/lazygit")

    if [ -z "$version" ]; then
        log_warn "نمی‌توان نسخه‌ی lazygit را دریافت کرد"
        version="0.62.2"
    fi

    local current=""
    if command -v lazygit &>/dev/null; then
        current=$(lazygit --version 2>/dev/null | grep -oP 'version=\K[0-9.]+' || echo "")
    fi

    if [ "$current" = "$version" ]; then
        log_success "lazygit v$version از قبل نصب است"
        return
    fi

    log_info "دانلود lazygit v$version... / Downloading lazygit v$version..."
    local arch_label="arm64"
    [ "$ARCH" = "x86_64" ] && arch_label="x86_64"

    local url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_${arch_label}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    if curl -fsSL "$url" -o "$tmp_dir/lazygit.tar.gz"; then
        tar -xzf "$tmp_dir/lazygit.tar.gz" -C "$tmp_dir" lazygit
        cp "$tmp_dir/lazygit" "$BIN_DIR/"
        chmod +x "$BIN_DIR/lazygit"
        log_success "lazygit v$version نصب شد"
    else
        log_warn "دانلود lazygit ناموفق بود"
    fi

    rm -rf "$tmp_dir"
}

# =============================================================================
# نصب zoxide / Install zoxide
# =============================================================================
install_zoxide() {
    log_info "نصب zoxide... / Installing zoxide..."
    local current=""
    if command -v zoxide &>/dev/null; then
        current=$(zoxide --version 2>/dev/null | grep -oP '[0-9.]+' | head -1 || echo "")
    fi

    local version
    version=$(get_latest_version "ajeetdsouza/zoxide")

    if [ "$current" = "$version" ]; then
        log_success "zoxide v$version از قبل نصب است"
        return
    fi

    log_info "دانلود zoxide v$version... / Downloading zoxide v$version..."
    if curl -sSf https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash -s -- --bin-dir "$BIN_DIR" 2>/dev/null; then
        log_success "zoxide نصب شد"
    else
        log_warn "نصب zoxide ناموفق بود"
    fi
}

# =============================================================================
# نصب fzf / Install fzf
# =============================================================================
install_fzf() {
    log_info "نصب fzf... / Installing fzf..."
    local version
    version=$(get_latest_version "junegunn/fzf")

    local current=""
    if command -v fzf &>/dev/null; then
        current=$(fzf --version 2>/dev/null | grep -oP '^[0-9.]+' || echo "")
    fi

    if [ "$current" = "$version" ]; then
        log_success "fzf v$version از قبل نصب است"
        return
    fi

    log_info "دانلود fzf v$version... / Downloading fzf v$version..."
    local arch_label="arm64"
    [ "$ARCH" = "x86_64" ] && arch_label="amd64"

    local url="https://github.com/junegunn/fzf/releases/download/v${version}/fzf-${version}-linux_${arch_label}.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    if curl -fsSL "$url" -o "$tmp_dir/fzf.tar.gz"; then
        tar -xzf "$tmp_dir/fzf.tar.gz" -C "$tmp_dir"
        cp "$tmp_dir/fzf" "$BIN_DIR/"
        chmod +x "$BIN_DIR/fzf"
        log_success "fzf v$version نصب شد"
    else
        log_warn "دانلود fzf ناموفق بود"
    fi

    rm -rf "$tmp_dir"
}

# =============================================================================
# نصب starship / Install starship
# =============================================================================
install_starship() {
    log_info "نصب starship... / Installing starship..."
    local version
    version=$(get_latest_version "starship/starship")

    local current=""
    if command -v starship &>/dev/null; then
        current=$(starship --version 2>/dev/null | grep -oP '^starship \K[0-9.]+' || echo "")
    fi

    if [ "$current" = "$version" ]; then
        log_success "starship v$version از قبل نصب است"
        return
    fi

    log_info "دانلود و نصب starship v$version... / Downloading and installing starship v$version..."
    if curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$BIN_DIR" 2>/dev/null; then
        log_success "starship نصب شد"
    else
        log_warn "نصب starship ناموفق بود"
    fi
}

# =============================================================================
# اجرای همه نصب‌ها / Run all installs
# =============================================================================
main() {
    install_yazi
    install_lazygit
    install_zoxide
    install_fzf
    install_starship

    log_success "همه‌ی باینری‌ها نصب/آپدیت شدند / All binaries installed/updated"
    log_info "مسیر / Path: $BIN_DIR"
}

main "$@"
