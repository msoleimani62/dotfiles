#!/usr/bin/env bash
# =============================================================================
# environments/generic-linux/install.sh
# نصب برای هر توزیع لینوکسی غیر از Kali/Arch - پکیج‌منیجر خودکار تشخیص داده می‌شود
# Install for any Linux distro other than Kali/Arch - package manager auto-detected
# =============================================================================

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }
log_error()   { echo -e "${RED}[✗]${RESET} $1"; }
log_section() { echo -e "\n${BOLD}${BLUE}▶ $1${RESET}\n"; }

# تشخیص پکیج‌منیجر موجود / Detect the available package manager
detect_pkg_manager() {
    if command -v apt &>/dev/null; then
        echo "apt"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    elif command -v zypper &>/dev/null; then
        echo "zypper"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    else
        echo "none"
    fi
}

main() {
    log_section "مرحله ۱: نصب پکیج‌های سیستمی / Step 1: Install system packages"

    PKG=$(detect_pkg_manager)
    log_info "پکیج‌منیجر تشخیص داده‌شده / Detected package manager: $PKG"

    case "$PKG" in
        apt)    bash "$DOTFILES_DIR/scripts/install_apt.sh" ;;
        dnf)    bash "$DOTFILES_DIR/scripts/install_dnf.sh" ;;
        zypper) bash "$DOTFILES_DIR/scripts/install_zypper.sh" ;;
        pacman) bash "$DOTFILES_DIR/scripts/install_pacman.sh" ;;
        *)
            log_error "پکیج‌منیجر شناخته‌شده‌ای پیدا نشد (apt/dnf/zypper/pacman)"
            log_error "No supported package manager found (apt/dnf/zypper/pacman)"
            log_warn "پکیج‌های زیر را دستی نصب کنید و دوباره اجرا کنید:"
            log_warn "Please install these manually and re-run:"
            echo "  tmux zsh zsh-autosuggestions zsh-syntax-highlighting bat eza ncdu"
            echo "  git neovim python3 python3-pip shellcheck ripgrep fd poppler-utils"
            echo "  htop curl wget unzip jq"
            exit 1
            ;;
    esac

    log_section "مرحله ۲: نصب/آپدیت باینری‌های مستقیم / Step 2: Install/update direct binaries"
    bash "$DOTFILES_DIR/scripts/install_binaries.sh"

    log_section "مرحله ۳: لینک کردن کانفیگ‌ها / Step 3: Link configs"
    bash "$DOTFILES_DIR/scripts/link_configs.sh"

    log_section "مرحله ۴: تنظیمات نهایی / Step 4: Final setup"

    if command -v zsh &>/dev/null && [ "$SHELL" != "$(which zsh)" ]; then
        log_info "تغییر شل پیش‌فرض به zsh... / Changing default shell to zsh..."
        chsh -s "$(which zsh)" 2>/dev/null || \
            log_warn "تغییر شل پیش‌فرض ناموفق بود - دستی انجام دهید: chsh -s $(which zsh)"
    fi

    log_success "نصب عمومی کامل شد! / Generic install complete!"
    echo ""
    echo "  برای اعمال تغییرات / To apply changes: source ~/.zshrc"
}

main "$@"
