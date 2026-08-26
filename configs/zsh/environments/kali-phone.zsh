# =============================================================================
# Kali NetHunter phone environment
# محیط اختصاصی Kali NetHunter روی گوشی
# =============================================================================

ZSH_ENV_FILE="${${(%):-%N}:A}"
ZSH_ENV_DIR="${ZSH_ENV_FILE:h}"

source "$ZSH_ENV_DIR/../modules/loader.zsh"

unset ZSH_ENV_FILE ZSH_ENV_DIR

# Start SSH daemon when entering an interactive Kali shell
# اجرای sshd هنگام ورود به شل تعاملی Kali
if command -v pgrep >/dev/null 2>&1 && command -v sudo >/dev/null 2>&1; then
    if ! pgrep -x sshd >/dev/null 2>&1; then
        sudo /usr/sbin/sshd 2>/dev/null || true
    fi
fi

# Define Kali package management shortcut
# تعریف میانبر مدیریت بسته‌های Kali
alias update="sudo apt update && sudo apt upgrade"

# Start X automatically on tty1 when no graphical session exists
# اجرای خودکار X روی tty1 در صورت نبود محیط گرافیکی
if [[ -z ${DISPLAY:-} && ${XDG_VTNR:-} == 1 && -x /usr/bin/startx ]]; then
    exec startx
fi

# Load Deno environment when available
# بارگذاری محیط Deno در صورت وجود
if [[ -f "$HOME/.deno/env" ]]; then
    source "$HOME/.deno/env"
fi

# Configure Python package management
# تنظیمات مدیریت بسته‌های Python
export UV_LINK_MODE="${UV_LINK_MODE:-copy}"

# Make pyenv available without loading its shell integration
# در دسترس قرار دادن pyenv بدون بارگذاری یکپارچه‌سازی shell
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

# Remove inherited pyenv shim paths from the shell environment
# حذف مسیرهای shim به‌ارث‌رسیده از محیط shell
path=(${path:#$PYENV_ROOT/shims})
path=(${path:#$PYENV_ROOT/plugins/pyenv-virtualenv/shims})


if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
    zsh_path_prepend "$PYENV_ROOT/bin"
fi

# Configure Java for the ARM64 Kali Android development environment
# تنظیم Java برای محیط توسعه Android روی Kali ARM64
if [[ -d /usr/lib/jvm/java-21-openjdk-arm64 ]]; then
    export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-arm64"
    zsh_path_prepend "$JAVA_HOME/bin"
fi

# Configure Android SDK paths when the SDK exists
# تنظیم مسیرهای Android SDK در صورت وجود SDK
export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

zsh_path_prepend \
    "$ANDROID_HOME/platform-tools" \
    "$ANDROID_HOME/cmdline-tools/latest/bin" \
    "$HOME/gradle-8.7/bin"

# Add the newest installed Android Build Tools directory
# افزودن جدیدترین نسخه نصب‌شده Android Build Tools
if [[ -d "$ANDROID_HOME/build-tools" ]]; then
    local_build_tools=("$ANDROID_HOME"/build-tools/*(/N))

    if (( ${#local_build_tools[@]} > 0 )); then
        newest_build_tools="$(
            printf '%s\n' "${local_build_tools[@]}" |
                sort -V |
                tail -n1
        )"

        if [[ -n "$newest_build_tools" ]]; then
            zsh_path_prepend "$newest_build_tools"
        fi
    fi

    unset local_build_tools newest_build_tools
fi

# Export the final PATH
# صادر کردن PATH نهایی
export PATH
