#!/usr/bin/env bash
# =============================================================================
# dotfiles - install.sh
# نقطه‌ی ورود اصلی - تشخیص محیط و اجرای نصب مناسب
# Main entry point - detects the environment and runs the matching installer
# =============================================================================

set -e

# نسخه‌ی این مجموعه dotfiles - برای چک نصب/آپدیت
# Version of this dotfiles collection - used for the install/update check
DOTFILES_VERSION="1.0.0"

# فایل نسخه بیرون از ریپو ذخیره می‌شود تا هیچ‌وقت با git diff قاطی نشود
# Version file lives outside the repo so it never shows up in git diff
VERSION_FILE="$HOME/.local/share/dotfiles/.version"

# رنگ‌ها برای خروجی / Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }
log_error()   { echo -e "${RED}[✗]${RESET} $1"; }
log_section() { echo -e "\n${BOLD}${BLUE}══════════════════════════════════${RESET}"; \
                echo -e "${BOLD}${BLUE}  $1${RESET}"; \
                echo -e "${BOLD}${BLUE}══════════════════════════════════${RESET}\n"; }

# پرچم --force برای اجرای کامل حتی اگر نسخه یکسان باشد (مفید موقع توسعه)
# --force flag to run fully even if the version matches (useful during dev)
FORCE=0
for arg in "$@"; do
    [ "$arg" = "--force" ] && FORCE=1
done

# تشخیص محیط: کالی گوشی / آرچ لپ‌تاپ / هر لینوکس دیگر
# Detect environment: Kali phone / Arch laptop / any other Linux
detect_environment() {
    if [ -f /etc/arch-release ]; then
        echo "arch-laptop"
    elif [ -f /etc/kali_version ] || grep -qi "kali" /etc/os-release 2>/dev/null; then
        echo "kali-phone"
    else
        # قبلاً اینجا "unknown" بود و اسکریپت متوقف می‌شد؛ حالا یک مسیر
        # عمومی برای هر توزیع لینوکسی دیگر در نظر گرفته شده است
        # Previously this fell through to "unknown" and stopped; now there is
        # a generic path for any other Linux distro
        echo "generic-linux"
    fi
}

main() {
    log_section "dotfiles installer"

    # ---- چک نسخه / Version check ----
    if [ -f "$VERSION_FILE" ] && [ "$FORCE" != "1" ]; then
        INSTALLED_VERSION="$(cat "$VERSION_FILE" 2>/dev/null || echo "0")"
        if [ "$INSTALLED_VERSION" = "$DOTFILES_VERSION" ]; then
            log_success "این نسخه از قبل نصب است ($INSTALLED_VERSION). کاری لازم نیست."
            log_success "Already up to date (version $INSTALLED_VERSION). Nothing to do."
            log_info "برای اجرای کامل و اجباری: bash install.sh --force"
            log_info "To force a full reinstall: bash install.sh --force"
            exit 0
        else
            log_info "نسخه‌ی قدیمی‌تر یافت شد ($INSTALLED_VERSION) → ارتقا به $DOTFILES_VERSION"
            log_info "Older version found ($INSTALLED_VERSION) → upgrading to $DOTFILES_VERSION"
        fi
    elif [ "$FORCE" = "1" ]; then
        log_info "اجرای اجباری با --force، چک نسخه رد شد / Forced run via --force, skipping version check"
    else
        log_info "نصب قبلی پیدا نشد، نصب از صفر شروع می‌شود / No previous install found, starting fresh"
    fi

    ENV=$(detect_environment)
    log_info "محیط تشخیص داده‌شده / Detected environment: ${BOLD}$ENV${RESET}"

    case "$ENV" in
        kali-phone)
            log_info "اجرای نصب برای Kali NetHunter (گوشی)... / Installing for Kali NetHunter (phone)..."
            bash "$DOTFILES_DIR/environments/kali-phone/install.sh"
            ;;
        arch-laptop)
            log_info "اجرای نصب برای Arch Linux (لپ‌تاپ)... / Installing for Arch Linux (laptop)..."
            bash "$DOTFILES_DIR/environments/arch-laptop/install.sh"
            ;;
        generic-linux)
            log_info "اجرای نصب عمومی برای این توزیع لینوکس... / Running generic install for this Linux distro..."
            bash "$DOTFILES_DIR/environments/generic-linux/install.sh"
            ;;
    esac

    # ---- ثبت نسخه پس از نصب موفق / Record version after a successful install ----
    mkdir -p "$(dirname "$VERSION_FILE")"
    echo "$DOTFILES_VERSION" > "$VERSION_FILE"

    log_section "نصب کامل شد! / Installation complete!"
    log_success "لطفاً ترمینال را ببندید و دوباره باز کنید تا تغییرات اعمال شوند."
    log_success "Please close and reopen your terminal for changes to take effect."
}

main "$@"
