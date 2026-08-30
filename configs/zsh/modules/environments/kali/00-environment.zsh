alias update="sudo apt update && sudo apt upgrade"

export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
    zsh_path_remove "$PYENV_ROOT/shims" "$PYENV_ROOT/plugins/pyenv-virtualenv/shims"
    zsh_path_prepend "$PYENV_ROOT/bin"
    eval "$("$PYENV_ROOT/bin/pyenv" init - zsh)"

    if [[ -x "$PYENV_ROOT/bin/pyenv-virtualenv-init" ]]; then
        eval "$("$PYENV_ROOT/bin/pyenv" virtualenv-init -)"
    fi
fi
