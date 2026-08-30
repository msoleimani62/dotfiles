if [[ -n "${DOTFILES_ZSH_LOADING:-}" ]]; then
    return 1
fi

typeset -g DOTFILES_ZSH_LOADING=1
typeset -g ZSH_MODULE_DIR="${${(%):-%N}:A:h}"

_dotfiles_load_shared_modules() {
    local module_file
    local -a module_files

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
}

_dotfiles_capture_environment_baseline() {
    typeset -g DOTFILES_ZSH_BASELINE_PATH="$PATH"

    if [[ -v JAVA_HOME ]]; then
        typeset -g DOTFILES_ZSH_BASELINE_JAVA_HOME="$JAVA_HOME"
        typeset -g DOTFILES_ZSH_BASELINE_JAVA_HOME_SET=1
    else
        unset DOTFILES_ZSH_BASELINE_JAVA_HOME
        typeset -g DOTFILES_ZSH_BASELINE_JAVA_HOME_SET=0
    fi

    if [[ -v ANDROID_HOME ]]; then
        typeset -g DOTFILES_ZSH_BASELINE_ANDROID_HOME="$ANDROID_HOME"
        typeset -g DOTFILES_ZSH_BASELINE_ANDROID_HOME_SET=1
    else
        unset DOTFILES_ZSH_BASELINE_ANDROID_HOME
        typeset -g DOTFILES_ZSH_BASELINE_ANDROID_HOME_SET=0
    fi

    if [[ -v ANDROID_SDK_ROOT ]]; then
        typeset -g DOTFILES_ZSH_BASELINE_ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
        typeset -g DOTFILES_ZSH_BASELINE_ANDROID_SDK_ROOT_SET=1
    else
        unset DOTFILES_ZSH_BASELINE_ANDROID_SDK_ROOT
        typeset -g DOTFILES_ZSH_BASELINE_ANDROID_SDK_ROOT_SET=0
    fi

    if [[ -v PYENV_ROOT ]]; then
        typeset -g DOTFILES_ZSH_BASELINE_PYENV_ROOT="$PYENV_ROOT"
        typeset -g DOTFILES_ZSH_BASELINE_PYENV_ROOT_SET=1
    else
        unset DOTFILES_ZSH_BASELINE_PYENV_ROOT
        typeset -g DOTFILES_ZSH_BASELINE_PYENV_ROOT_SET=0
    fi

    if [[ -v UV_LINK_MODE ]]; then
        typeset -g DOTFILES_ZSH_BASELINE_UV_LINK_MODE="$UV_LINK_MODE"
        typeset -g DOTFILES_ZSH_BASELINE_UV_LINK_MODE_SET=1
    else
        unset DOTFILES_ZSH_BASELINE_UV_LINK_MODE
        typeset -g DOTFILES_ZSH_BASELINE_UV_LINK_MODE_SET=0
    fi
}

_dotfiles_capture_shared_baseline() {
    typeset -g DOTFILES_ZSH_SHARED_BASELINE_PATH="$PATH"

    if [[ -v JAVA_HOME ]]; then
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_JAVA_HOME="$JAVA_HOME"
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_JAVA_HOME_SET=1
    else
        unset DOTFILES_ZSH_SHARED_BASELINE_JAVA_HOME
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_JAVA_HOME_SET=0
    fi

    if [[ -v ANDROID_HOME ]]; then
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_ANDROID_HOME="$ANDROID_HOME"
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_ANDROID_HOME_SET=1
    else
        unset DOTFILES_ZSH_SHARED_BASELINE_ANDROID_HOME
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_ANDROID_HOME_SET=0
    fi

    if [[ -v ANDROID_SDK_ROOT ]]; then
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_ANDROID_SDK_ROOT="$ANDROID_SDK_ROOT"
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_ANDROID_SDK_ROOT_SET=1
    else
        unset DOTFILES_ZSH_SHARED_BASELINE_ANDROID_SDK_ROOT
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_ANDROID_SDK_ROOT_SET=0
    fi

    if [[ -v PYENV_ROOT ]]; then
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_PYENV_ROOT="$PYENV_ROOT"
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_PYENV_ROOT_SET=1
    else
        unset DOTFILES_ZSH_SHARED_BASELINE_PYENV_ROOT
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_PYENV_ROOT_SET=0
    fi

    if [[ -v UV_LINK_MODE ]]; then
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_UV_LINK_MODE="$UV_LINK_MODE"
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_UV_LINK_MODE_SET=1
    else
        unset DOTFILES_ZSH_SHARED_BASELINE_UV_LINK_MODE
        typeset -g DOTFILES_ZSH_SHARED_BASELINE_UV_LINK_MODE_SET=0
    fi
}

_dotfiles_restore_environment_baseline() {
    path=("${(@s/:/)DOTFILES_ZSH_SHARED_BASELINE_PATH}")

    if [[ "${DOTFILES_ZSH_SHARED_BASELINE_JAVA_HOME_SET:-0}" == 1 ]]; then
        export JAVA_HOME="$DOTFILES_ZSH_SHARED_BASELINE_JAVA_HOME"
    else
        unset JAVA_HOME
    fi

    if [[ "${DOTFILES_ZSH_SHARED_BASELINE_ANDROID_HOME_SET:-0}" == 1 ]]; then
        export ANDROID_HOME="$DOTFILES_ZSH_SHARED_BASELINE_ANDROID_HOME"
    else
        unset ANDROID_HOME
    fi

    if [[ "${DOTFILES_ZSH_SHARED_BASELINE_ANDROID_SDK_ROOT_SET:-0}" == 1 ]]; then
        export ANDROID_SDK_ROOT="$DOTFILES_ZSH_SHARED_BASELINE_ANDROID_SDK_ROOT"
    else
        unset ANDROID_SDK_ROOT
    fi

    if [[ "${DOTFILES_ZSH_SHARED_BASELINE_PYENV_ROOT_SET:-0}" == 1 ]]; then
        export PYENV_ROOT="$DOTFILES_ZSH_SHARED_BASELINE_PYENV_ROOT"
    else
        unset PYENV_ROOT
    fi

    if [[ "${DOTFILES_ZSH_SHARED_BASELINE_UV_LINK_MODE_SET:-0}" == 1 ]]; then
        export UV_LINK_MODE="$DOTFILES_ZSH_SHARED_BASELINE_UV_LINK_MODE"
    else
        unset UV_LINK_MODE
    fi
}

_dotfiles_environment_leave() {
    local environment
    local leave_function

    environment="${DOTFILES_ZSH_ENV_LOADED:-}"

    if [[ -z "$environment" ]]; then
        _dotfiles_restore_environment_baseline || return 1
        return 0
    fi

    leave_function="_dotfiles_env_leave_${environment}"

    if typeset -f "$leave_function" >/dev/null 2>&1; then
        "$leave_function" || return 1
    fi

    _dotfiles_restore_environment_baseline || return 1

    unset DOTFILES_ZSH_ENV_LOADED

    return 0
}

_dotfiles_environment_enter() {
    local environment
    local environment_module_dir
    local module_file
    local -a environment_modules

    environment="$1"
    environment_module_dir="$ZSH_MODULE_DIR/environments/$environment"

    [[ -d "$environment_module_dir" ]] || return 1

    environment_modules=("$environment_module_dir"/*.zsh(N))

    (( ${#environment_modules} > 0 )) || return 1

    for module_file in "${environment_modules[@]}"; do
        source "$module_file" || return 1
    done

    typeset -g DOTFILES_ZSH_ENV_LOADED="$environment"

    return 0
}

dotfiles_switch_environment() {
    local environment
    local previous_environment

    environment="${1:-${DOTFILES_ZSH_ENV:-generic}}"
    previous_environment="${DOTFILES_ZSH_ENV_LOADED:-}"

    [[ -d "$ZSH_MODULE_DIR/environments/$environment" ]] || return 1

    if [[ "$previous_environment" == "$environment" ]]; then
        return 0
    fi

    if ! _dotfiles_environment_leave; then
        return 1
    fi

    if _dotfiles_environment_enter "$environment"; then
        typeset -g DOTFILES_ZSH_ENV="$environment"
        return 0
    fi

    if [[ -n "$previous_environment" ]]; then
        if _dotfiles_environment_enter "$previous_environment"; then
            typeset -g DOTFILES_ZSH_ENV="$previous_environment"
            return 1
        fi
    else
        _dotfiles_restore_environment_baseline
    fi

    unset DOTFILES_ZSH_ENV_LOADED

    return 1
}

if [[ -z "${DOTFILES_ZSH_LOADED:-}" ]]; then
    _dotfiles_capture_environment_baseline || {
        unset -f _dotfiles_load_shared_modules
        unset -f _dotfiles_capture_environment_baseline
        unset -f _dotfiles_capture_shared_baseline
        unset -f _dotfiles_restore_environment_baseline
        unset -f _dotfiles_environment_leave
        unset -f _dotfiles_environment_enter
        unset -f dotfiles_switch_environment
        unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR DOTFILES_ZSH_LOADED
        return 1
    }

    _dotfiles_load_shared_modules || {
        unset -f _dotfiles_load_shared_modules
        unset -f _dotfiles_capture_environment_baseline
        unset -f _dotfiles_capture_shared_baseline
        unset -f _dotfiles_restore_environment_baseline
        unset -f _dotfiles_environment_leave
        unset -f _dotfiles_environment_enter
        unset -f dotfiles_switch_environment
        unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR DOTFILES_ZSH_LOADED
        return 1
    }

    _dotfiles_capture_shared_baseline || {
        unset -f _dotfiles_load_shared_modules
        unset -f _dotfiles_capture_environment_baseline
        unset -f _dotfiles_capture_shared_baseline
        unset -f _dotfiles_restore_environment_baseline
        unset -f _dotfiles_environment_leave
        unset -f _dotfiles_environment_enter
        unset -f dotfiles_switch_environment
        unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR DOTFILES_ZSH_LOADED
        return 1
    }

    typeset -g DOTFILES_ZSH_LOADED=1
fi

if ! dotfiles_switch_environment "${1:-${DOTFILES_ZSH_ENV:-generic}}"; then
    unset -f _dotfiles_load_shared_modules
    unset -f _dotfiles_capture_environment_baseline
    unset -f _dotfiles_restore_environment_baseline
    unset -f _dotfiles_environment_leave
    unset -f _dotfiles_environment_enter
    unset -f dotfiles_switch_environment
    unset DOTFILES_ZSH_LOADING ZSH_MODULE_DIR DOTFILES_ZSH_LOADED
    return 1
fi

unset -f _dotfiles_load_shared_modules
unset DOTFILES_ZSH_LOADING
