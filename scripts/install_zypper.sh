#!/usr/bin/env bash
# =============================================================================
# scripts/install_zypper.sh
# نصب پکیج‌ها روی openSUSE با zypper
# Installs packages on openSUSE via zypper
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }

ZYPPER_PACKAGES=(
    tmux zsh
    zsh-autosuggestions zsh-syntax-highlighting
    bat eza ncdu
    git neovim python3 python3-pip
    ShellCheck tealdeer ripgrep fd poppler-tools
    htop curl wget unzip jq
)

install_zypper_packages() {
    log_info "نصب پکیج‌ها با zypper... / Installing packages with zypper..."
    sudo zypper --non-interactive install "${ZYPPER_PACKAGES[@]}" 2>/dev/null || \
        log_warn "بعضی پکیج‌ها نصب نشدند (ممکن است نیاز به فعال‌سازی مخزن اضافه باشد) / Some packages failed (may need an extra repo enabled)"

    log_success "پکیج‌های zypper نصب شدند"
}

install_yazi_plugins() {
    local ya_bin="$HOME/.local/bin/ya"
    if [ ! -x "$ya_bin" ]; then
        log_warn "ya پیدا نشد، پلاگین‌های yazi رد شد"
        return
    fi
    log_info "آپدیت پلاگین‌های yazi..."
    "$ya_bin" pkg upgrade 2>/dev/null && log_success "پلاگین‌های yazi آپدیت شدند" || log_warn "آپدیت پلاگین‌ها ناموفق بود"
}

update_tldr() {
    if command -v tldr &>/dev/null; then
        tldr --update 2>/dev/null && log_success "کش tldr آپدیت شد" || true
    fi
}

main() {
    install_zypper_packages
    install_yazi_plugins
    update_tldr
}

main "$@"
