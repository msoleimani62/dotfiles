#!/usr/bin/env bash
# =============================================================================
# environments/kali-phone/install.sh
# نصب/آپدیت کامل محیط Kali NetHunter روی گوشی
# Full install/update for the Kali NetHunter (phone) environment
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }
log_section() { echo -e "\n${BOLD}${BLUE}▶ $1${RESET}\n"; }

main() {
    log_section "مرحله ۱: نصب پکیج‌های apt / Step 1: Install apt packages"
    bash "$DOTFILES_DIR/scripts/install_apt.sh"

    log_section "مرحله ۲: نصب/آپدیت باینری‌های مستقیم / Step 2: Install/update direct binaries"
    bash "$DOTFILES_DIR/scripts/install_binaries.sh"

    log_section "مرحله ۳: لینک کردن کانفیگ‌ها / Step 3: Link configs"
    bash "$DOTFILES_DIR/scripts/link_configs.sh"

    log_section "مرحله ۴: تنظیمات نهایی / Step 4: Final setup"

    # تنظیم zsh به‌عنوان شل پیش‌فرض (اگه نباشه)
    # Set zsh as default shell (if not already)
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "تغییر شل پیش‌فرض به zsh... / Changing default shell to zsh..."
        chsh -s "$(which zsh)" 2>/dev/null || \
            log_warn "تغییر شل پیش‌فرض ناموفق بود - دستی انجام دهید: chsh -s $(which zsh)"
    fi

    # آپدیت پلاگین‌های yazi / Update yazi plugins
    if command -v ya &>/dev/null; then
        log_info "آپدیت پلاگین‌های yazi... / Updating yazi plugins..."
        command ya pkg upgrade 2>/dev/null || true
    fi

    log_success "نصب کامل محیط کالی گوشی انجام شد! / Kali phone environment install complete!"
    echo ""
    echo "  برای اعمال تغییرات / To apply changes: source ~/.zshrc"
    echo "  یا ترمینال را ببندید و دوباره باز کنید / or close and reopen your terminal"
}

main "$@"
