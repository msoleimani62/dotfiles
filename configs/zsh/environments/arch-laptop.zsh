# =============================================================================
# Arch Linux laptop environment
# محیط اختصاصی Arch Linux روی لپ‌تاپ
# =============================================================================

ZSH_ENV_FILE="${${(%):-%N}:A}"
ZSH_ENV_DIR="${ZSH_ENV_FILE:h}"

source "$ZSH_ENV_DIR/../modules/loader.zsh"

unset ZSH_ENV_FILE ZSH_ENV_DIR

# Define the Arch Linux package management shortcut
# تعریف میانبر مدیریت بسته‌های Arch Linux
alias update="sudo pacman -Syu"

# Start X automatically on tty1 when no graphical session exists
# اجرای خودکار X روی tty1 در صورت نبود محیط گرافیکی
if [[ -z ${DISPLAY:-} && ${XDG_VTNR:-} == 1 && -x /usr/bin/startx ]]; then
    exec startx
fi

export PATH
