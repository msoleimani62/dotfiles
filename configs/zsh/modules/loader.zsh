# =============================================================================
# Zsh module loader
# بارگذار ماژول‌های Zsh
# =============================================================================

if [[ -n "${DOTFILES_ZSH_LOADED:-}" ]]; then
    return 0
fi

typeset -g DOTFILES_ZSH_LOADED=1

ZSH_MODULE_DIR="${${(%):-%N}:A:h}"

source "$ZSH_MODULE_DIR/00-core.zsh"
source "$ZSH_MODULE_DIR/10-path.zsh"
source "$ZSH_MODULE_DIR/20-completion.zsh"
source "$ZSH_MODULE_DIR/30-tools.zsh"
source "$ZSH_MODULE_DIR/40-aliases.zsh"
source "$ZSH_MODULE_DIR/50-local.zsh"
source "$ZSH_MODULE_DIR/90-plugins.zsh"

unset ZSH_MODULE_DIR
