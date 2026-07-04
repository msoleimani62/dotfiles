#!/usr/bin/env bash
# =============================================================================
# scripts/install_apt.sh
# نصب پکیج‌ها روی سیستم‌های مبتنی بر apt (Debian, Ubuntu, Kali, ...)
# Installs packages on apt-based systems (Debian, Ubuntu, Kali, ...)
# =============================================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

log_info()    { echo -e "${CYAN}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[✓]${RESET} $1"; }
log_warn()    { echo -e "${YELLOW}[!]${RESET} $1"; }

# ---------------------------------------------------------------------------
# فیکس‌های زیر (تغییر mirror و wrapper systemd) فقط مخصوص Kali NetHunter
# proot هستند. قبلاً بدون هیچ پرسشی روی هر سیستم apt اجرا می‌شدند که
# می‌توانست sources.list یک Debian/Ubuntu واقعی را خراب کند. حالا فقط با
# تأیید صریح کاربر اجرا می‌شوند.
#
# The fixes below (mirror change, systemd wrappers) are Kali NetHunter
# proot-specific only. They used to run unconditionally on any apt system,
# which could break sources.list on a real Debian/Ubuntu install. They now
# require explicit user confirmation.
# ---------------------------------------------------------------------------
IS_PROOT_KALI="${IS_PROOT_KALI:-}"
if [ -z "$IS_PROOT_KALI" ]; then
    if [ -t 0 ] && grep -qi "kali" /etc/os-release 2>/dev/null; then
        read -p "Running inside Kali NetHunter proot? Apply mirror/dpkg fixes? [y/N]: " ans
        case "$ans" in
            y|Y|yes|Yes) IS_PROOT_KALI="yes" ;;
            *) IS_PROOT_KALI="no" ;;
        esac
    else
        IS_PROOT_KALI="no"
    fi
fi

# آدرس mirror قابل تنظیم با متغیر محیطی است، پیش‌فرض redirector رسمی کالی
# است (نه یک mirror کشوری خاص) تا برای همه قابل استفاده باشد
# Mirror is configurable via env var; default is Kali's official redirector
# (not a country-specific mirror) so it works for everyone
KALI_MIRROR="${KALI_MIRROR:-http://http.kali.org/kali}"

setup_mirror() {
    log_info "تنظیم mirror کالی... / Setting up Kali mirror..."
    echo "deb ${KALI_MIRROR} kali-rolling main contrib non-free non-free-firmware" \
        | sudo tee /etc/apt/sources.list > /dev/null
    log_success "Mirror تنظیم شد: $KALI_MIRROR"
}

fix_proot_dpkg() {
    log_info "رفع مشکل dpkg در محیط proot... / Fixing dpkg for the proot environment..."

    if [ ! -f /usr/sbin/policy-rc.d ]; then
        sudo tee /usr/sbin/policy-rc.d > /dev/null << 'EOF'
#!/bin/sh
exit 101
EOF
        sudo chmod +x /usr/sbin/policy-rc.d
        log_success "policy-rc.d ساخته شد"
    fi

    if [ ! -f /usr/bin/systemd-sysusers.real ]; then
        sudo cp /usr/bin/systemd-sysusers /usr/bin/systemd-sysusers.real 2>/dev/null || true
        sudo tee /usr/bin/systemd-sysusers > /dev/null << 'EOF'
#!/bin/sh
exit 0
EOF
        sudo chmod +x /usr/bin/systemd-sysusers
        log_success "systemd-sysusers wrapper ساخته شد"
    fi

    if [ ! -f /usr/bin/systemd-tmpfiles.real ]; then
        sudo cp /usr/bin/systemd-tmpfiles /usr/bin/systemd-tmpfiles.real 2>/dev/null || true
        sudo tee /usr/bin/systemd-tmpfiles > /dev/null << 'EOF'
#!/bin/sh
exit 0
EOF
        sudo chmod +x /usr/bin/systemd-tmpfiles
        log_success "systemd-tmpfiles wrapper ساخته شد"
    fi
}

# لیست پکیج‌ها؛ zsh-autosuggestions و zsh-syntax-highlighting قبلاً از قلم
# افتاده بودند با این‌که .zshrc آن‌ها را source می‌کرد
# Package list; zsh-autosuggestions and zsh-syntax-highlighting were
# previously missing even though .zshrc sourced them
APT_PACKAGES=(
    tmux zsh
    zsh-autosuggestions zsh-syntax-highlighting
    bat eza ncdu
    git neovim python3 python3-pip
    shellcheck tealdeer ripgrep fd-find poppler-utils
    htop curl wget unzip jq
)

install_apt_packages() {
    log_info "آپدیت لیست پکیج‌ها... / Updating package list..."
    sudo apt update -qq

    log_info "نصب پکیج‌های apt... / Installing apt packages..."
    sudo apt install -y "${APT_PACKAGES[@]}" 2>/dev/null || \
        log_warn "بعضی پکیج‌ها نصب نشدند، ادامه می‌دهیم... / Some packages failed to install, continuing..."

    if command -v batcat &>/dev/null && [ ! -f /usr/local/bin/bat ]; then
        sudo ln -sf /usr/bin/batcat /usr/local/bin/bat 2>/dev/null || true
        log_success "symlink bat ساخته شد"
    fi

    if command -v fdfind &>/dev/null && [ ! -f /usr/local/bin/fd ]; then
        sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd 2>/dev/null || true
        log_success "symlink fd ساخته شد"
    fi

    log_success "پکیج‌های apt نصب شدند"
}

install_yazi_plugins() {
    local ya_bin="$HOME/.local/bin/ya"

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
    if [ "$IS_PROOT_KALI" = "yes" ]; then
        setup_mirror
        fix_proot_dpkg
    else
        log_info "رد شدن از تنظیمات مخصوص proot کالی / Skipping Kali-proot-specific fixes"
    fi
    install_apt_packages
    install_yazi_plugins
    update_tldr
}

main "$@"
