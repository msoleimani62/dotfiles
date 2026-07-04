#!/usr/bin/env bash
# =============================================================================
# environments/arch-laptop/install.sh
# نصب/آپدیت کامل محیط Arch Linux روی لپ‌تاپ
# Full install/update for the Arch Linux (laptop) environment
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_section() { echo -e "\n${BOLD}${BLUE}▶ $1${RESET}\n"; }

main() {
    log_section "مرحله ۱: نصب پکیج‌های pacman / Step 1: Install pacman packages"
    bash "$DOTFILES_DIR/scripts/install_pacman.sh"

    log_section "مرحله ۲: نصب/آپدیت باینری‌های مستقیم / Step 2: Install/update direct binaries"
    bash "$DOTFILES_DIR/scripts/install_binaries.sh"

    log_section "مرحله ۳: لینک کردن کانفیگ‌ها / Step 3: Link configs"
    bash "$DOTFILES_DIR/scripts/link_configs.sh"

    log_section "مرحله ۴: تنظیمات نهایی / Step 4: Final setup"

    local current_shell
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
    local zsh_path
    zsh_path=$(which zsh)
    if [ "$current_shell" != "$zsh_path" ]; then
        log_info "تغییر شل پیش‌فرض به zsh... / Changing default shell to zsh..."
        chsh -s "$zsh_path"
        log_success "شل پیش‌فرض به zsh تغییر کرد / Default shell changed to zsh"
    else
        log_success "شل پیش‌فرض از قبل zsh است / Default shell is already zsh"
    fi

    log_success "نصب کامل محیط آرچ لپ‌تاپ انجام شد! / Arch laptop environment install complete!"
    echo ""
    echo "  برای اعمال تغییرات / To apply changes: source ~/.zshrc"
}

main "$@"
