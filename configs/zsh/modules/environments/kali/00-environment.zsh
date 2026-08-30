_dotfiles_env_leave_kali() {
    zsh_path_remove \
        "$HOME/.pyenv/shims" \
        "$HOME/.pyenv/bin" \
        "${JAVA_HOME:-}/bin" \
        "${ANDROID_HOME:-}/platform-tools" \
        "${ANDROID_HOME:-}/cmdline-tools/latest/bin"

    if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME/build-tools" ]]; then
        local build_tools_dir

        for build_tools_dir in "$ANDROID_HOME"/build-tools/*(N); do
            zsh_path_remove "$build_tools_dir"
        done
    fi

    if [[ -n "${HOME:-}" ]]; then
        local gradle_dir

        for gradle_dir in "$HOME"/gradle-*/bin(N); do
            zsh_path_remove "$gradle_dir"
        done
    fi

    if typeset -f pyenv >/dev/null 2>&1; then
        unfunction pyenv
    fi

    if typeset -f pyenv_virtualenv_hook >/dev/null 2>&1; then
        unfunction pyenv_virtualenv_hook
    fi

    if (( ${+precmd_functions} )); then
        precmd_functions=(${precmd_functions:#pyenv_virtualenv_hook})
    fi

    if (( ${+chpwd_functions} )); then
        chpwd_functions=(${chpwd_functions:#pyenv_virtualenv_hook})
    fi

    unset \
        JAVA_HOME \
        ANDROID_HOME \
        ANDROID_SDK_ROOT \
        UV_LINK_MODE \
        PYENV_ROOT
}

alias update="sudo apt update && sudo apt upgrade"

export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
    zsh_path_remove "$PYENV_ROOT/shims" "$PYENV_ROOT/plugins/pyenv-virtualenv/shims"
    zsh_path_prepend "$PYENV_ROOT/bin"
    zsh_path_prepend "$PYENV_ROOT/shims"

    eval "$("$PYENV_ROOT/bin/pyenv" init --no-rehash - zsh)"

    if [[ -x "$PYENV_ROOT/bin/pyenv-virtualenv-init" ]]; then
        eval "$("$PYENV_ROOT/bin/pyenv" virtualenv-init -)"
    fi
fi
