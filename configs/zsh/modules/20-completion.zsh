# Completion and line editor configuration

autoload -Uz compinit

XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
ZSH_COMPDUMP_DIR="$XDG_CACHE_HOME/zsh"
ZSH_COMPDUMP="$ZSH_COMPDUMP_DIR/zcompdump-${ZSH_VERSION}"

if [[ ! -d "$ZSH_COMPDUMP_DIR" ]]; then
    mkdir -p -- "$ZSH_COMPDUMP_DIR"
fi

compinit -d "$ZSH_COMPDUMP"

bindkey -e
