autoload -Uz compinit

XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
ZSH_COMPDUMP_DIR="$XDG_CACHE_HOME/zsh"
ZSH_COMPDUMP="$ZSH_COMPDUMP_DIR/zcompdump-${ZSH_VERSION}"

if [[ ! -d "$ZSH_COMPDUMP_DIR" ]]; then
    mkdir -p -- "$ZSH_COMPDUMP_DIR" || return 1
fi

if [[ -r "$ZSH_COMPDUMP" ]]; then
    compinit -C -d "$ZSH_COMPDUMP" || return 1
else
    compinit -d "$ZSH_COMPDUMP" || return 1
fi

bindkey -e
