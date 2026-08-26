# =============================================================================
# Completion and line editor configuration
# تنظیمات تکمیل خودکار و ویرایشگر خط فرمان
# =============================================================================

autoload -Uz compinit
autoload -Uz add-zsh-hook

XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
ZSH_COMPDUMP_DIR="$XDG_CACHE_HOME/zsh"

if [[ ! -d "$ZSH_COMPDUMP_DIR" ]]; then
    mkdir -p "$ZSH_COMPDUMP_DIR"
fi

compinit -C -d "$ZSH_COMPDUMP_DIR/zcompdump-${ZSH_VERSION}"

bindkey -e
bindkey '\e' kill-whole-line
