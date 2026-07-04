#!/usr/bin/env bash
# =============================================================================
# scripts/install_dnf.sh
# نصب پکیج‌ها روی فدورا/RHEL/CentOS با dnf
# Installs packages on Fedora/RHEL/CentOS via dnf
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }

DNF_PACKAGES=(
    tmux zsh
    zsh-autosuggestions zsh-syntax-highlighting
    bat eza ncdu
    git neovim python3 python3-pip
    ShellCheck tealdeer ripgrep fd-find poppler-utils
    htop curl wget unzip jq
)

install_dnf_packages() {
    log_info "نصب پکیج‌ها با dnf... / Installing packages with dnf..."
    sudo dnf install -y "${DNF_PACKAGES[@]}" 2>/dev/null || \
        log_warn "بعضی پکیج‌ها نصب نشدند (ممکن است نیاز به فعال‌سازی RPM Fusion/COPR باشد) / Some packages failed (may need RPM Fusion/COPR enabled)"

    log_success "پکیج‌های dnf نصب شدند"
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
    install_dnf_packages
    install_yazi_plugins
    update_tldr
}

main "$@"
