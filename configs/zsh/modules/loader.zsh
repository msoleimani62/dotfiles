# Zsh module loader

if [[ -n "${DOTFILES_ZSH_LOADED:-}" ]]; then
    return 0
fi

if [[ -n "${DOTFILES_ZSH_LOADING:-}" ]]; then
    return 1
fi

typeset -g DOTFILES_ZSH_LOADING=1
typeset -g ZSH_MODULE_DIR="${${(%):-%N}:A:h}"

source "$ZSH_MODULE_DIR/00-core.zsh" || {
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
    return 1
}

source "$ZSH_MODULE_DIR/10-path.zsh" || {
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
    return 1
}

source "$ZSH_MODULE_DIR/20-completion.zsh" || {
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
    return 1
}

source "$ZSH_MODULE_DIR/30-tools.zsh" || {
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
    return 1
}

source "$ZSH_MODULE_DIR/40-aliases.zsh" || {
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
    return 1
}

source "$ZSH_MODULE_DIR/50-local.zsh" || {
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
    return 1
}

source "$ZSH_MODULE_DIR/90-plugins.zsh" || {
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
    return 1
}

unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
typeset -g DOTFILES_ZSH_LOADED=1
