if [[ -n "${DOTFILES_ZSH_LOADED:-}" ]]; then
    return 0
fi

if [[ -n "${DOTFILES_ZSH_LOADING:-}" ]]; then
    return 1
fi

typeset -g DOTFILES_ZSH_LOADING=1
typeset -g ZSH_MODULE_DIR="${${(%):-%N}:A:h}"
typeset -g DOTFILES_ZSH_ENV="${DOTFILES_ZSH_ENV:-generic}"

_dotfiles_load_modules() {
    local module_file
    local environment_module_dir
    local -a module_files
    local -a environment_modules

    module_files=(
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

    environment_module_dir="$ZSH_MODULE_DIR/environments/$DOTFILES_ZSH_ENV"

    if [[ -d "$environment_module_dir" ]]; then
        environment_modules=("$environment_module_dir"/*.zsh(N))

        for module_file in "${environment_modules[@]}"; do
            source "$module_file" || return 1
        done
    fi
}

if ! _dotfiles_load_modules; then
    unset -f _dotfiles_load_modules
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR DOTFILES_ZSH_ENV
    return 1
fi

unset -f _dotfiles_load_modules
unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR
typeset -g DOTFILES_ZSH_LOADED=1
