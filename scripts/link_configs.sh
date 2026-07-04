#!/usr/bin/env bash
# =============================================================================
# scripts/link_configs.sh
# ساخت symlink از کانفیگ‌های dotfiles به مسیرهای اصلی
# Creates symlinks from dotfiles configs to their real locations
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }

# تشخیص محیط: حالا سه حالت دارد، نه دو حالت
# قبلاً هر چیزی غیر از arch به‌اشتباه kali در نظر گرفته می‌شد
# Detect environment: now three states instead of two.
# Previously anything other than arch was wrongly treated as kali
detect_env() {
    if [ -f /etc/arch-release ]; then
        echo "arch"
    elif [ -f /etc/kali_version ] || grep -qi "kali" /etc/os-release 2>/dev/null; then
        echo "kali"
    else
        echo "generic"
    fi
}

ENV=$(detect_env)

# ساخت symlink با پشتیبان‌گیری از فایل قدیمی
# Create a symlink, backing up any existing real file first
make_link() {
    local src="$1"
    local dst="$2"

    mkdir -p "$(dirname "$dst")"

    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        log_warn "بک‌آپ از $dst → ${dst}.backup / Backing up $dst → ${dst}.backup"
        mv "$dst" "${dst}.backup"
    fi

    ln -sf "$src" "$dst"
    log_success "لینک شد / Linked: $dst → $src"
}

link_configs() {
    log_info "لینک کردن کانفیگ‌های مشترک... / Linking shared configs..."

    # yazi
    make_link "$DOTFILES_DIR/configs/yazi/yazi.toml"    "$HOME/.config/yazi/yazi.toml"
    make_link "$DOTFILES_DIR/configs/yazi/keymap.toml"  "$HOME/.config/yazi/keymap.toml"
    make_link "$DOTFILES_DIR/configs/yazi/theme.toml"   "$HOME/.config/yazi/theme.toml"
    make_link "$DOTFILES_DIR/configs/yazi/init.lua"     "$HOME/.config/yazi/init.lua"

    # starship
    make_link "$DOTFILES_DIR/configs/starship.toml"     "$HOME/.config/starship.toml"

    # zsh - مشترک / shared
    make_link "$DOTFILES_DIR/configs/zsh/.zshrc.base"   "$HOME/.zshrc.base"

    # zsh - خاص محیط / environment-specific
    case "$ENV" in
        arch)
            make_link "$DOTFILES_DIR/configs/zsh/.zshrc.arch-laptop" "$HOME/.zshrc"
            ;;
        kali)
            make_link "$DOTFILES_DIR/configs/zsh/.zshrc.kali-phone"  "$HOME/.zshrc"
            ;;
        generic)
            make_link "$DOTFILES_DIR/configs/zsh/.zshrc.generic"    "$HOME/.zshrc"
            ;;
    esac

    log_success "همه‌ی کانفیگ‌ها لینک شدند / All configs linked"
    log_info "برای تنظیمات شخصی و خصوصی (مثل alias های SSH)، فایل"
    log_info "~/.zshrc.local را بسازید — این فایل هرگز به گیت اضافه نمی‌شود."
    log_info "For personal/private settings (e.g. SSH aliases), create"
    log_info "~/.zshrc.local — this file is never added to git."
}

link_configs
