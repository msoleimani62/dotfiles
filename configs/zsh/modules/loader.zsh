if [[ -n "${DOTFILES_ZSH_LOADED:-}" ]]; then
    return 0
fi

if [[ -n "${DOTFILES_ZSH_LOADING:-}" ]]; then
    return 1
fi

typeset -g DOTFILES_ZSH_LOADING=1
typeset -g ZSH_MODULE_DIR="${${(%):-%N}:A:h}"

_dotfiles_load_modules() {
    local module_file
    local -a module_files=(
        00-core.zsh
        10-path.zsh
        20-completion.zsh
        30-tools.zsh
        40-aliases.zsh
        50-local.zsh
        90-plugins.zsh
    )

    for module_file in "${module_files[@]}"; do
        source "$ZSH_MODULE_DIR/$module_file" || return 1
    done
}

if ! _dotfiles_load_modules; then
    unset -f _dotfiles_load_modules
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
    return 1
fi

unset -f _dotfiles_load_modules
unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
typeset -g DOTFILES_ZSH_LOADED=1
