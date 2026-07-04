#!/usr/bin/env bash
# =============================================================================
# scripts/install_pacman.sh
# نصب پکیج‌ها روی آرچ لینوکس / Installs packages on Arch Linux
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }

# zsh-autosuggestions و zsh-syntax-highlighting قبلاً از قلم افتاده بودند
# با این‌که .zshrc آن‌ها را source می‌کرد
# zsh-autosuggestions and zsh-syntax-highlighting were previously missing
# even though .zshrc sourced them
PACMAN_PACKAGES=(
    tmux zsh starship
    zsh-autosuggestions zsh-syntax-highlighting
    yazi ffmpegthumbnailer unarchiver
    eza bat ncdu zoxide fzf
    git neovim python python-pip
    shellcheck tealdeer ripgrep fd poppler
    btop curl wget unzip jq lazygit
)

install_pacman_packages() {
    log_info "آپدیت پکیج‌ها... / Updating packages..."
    sudo pacman -Syu --noconfirm

    log_info "نصب پکیج‌ها... / Installing packages..."
    sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"

    log_success "پکیج‌های pacman نصب شدند"
}

install_yazi_plugins() {
    local ya_bin
    ya_bin=$(which ya 2>/dev/null || echo "$HOME/.local/bin/ya")

    if [ ! -x "$ya_bin" ]; then
        log_warn "ya پیدا نشد، پلاگین‌های yazi رد شد"
        return
    fi

    log_info "آپدیت پلاگین‌های yazi... / Updating yazi plugins..."
    "$ya_bin" pkg upgrade 2>/dev/null && log_success "پلاگین‌های yazi آپدیت شدند" || log_warn "آپدیت پلاگین‌ها ناموفق بود"
}

update_tldr() {
    if command -v tldr &>/dev/null; then
        log_info "آپدیت کش tldr... / Updating tldr cache..."
        tldr --update 2>/dev/null && log_success "کش tldr آپدیت شد" || true
    fi
}

main() {
    install_pacman_packages
    install_yazi_plugins
    update_tldr
}

main "$@"
