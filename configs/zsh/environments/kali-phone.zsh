# Kali NetHunter phone environment

ZSH_ENV_FILE="${${(%):-%N}:A}"
ZSH_ENV_DIR="${ZSH_ENV_FILE:h}"

source "$ZSH_ENV_DIR/../modules/loader.zsh" || return 1

unset ZSH_ENV_FILE ZSH_ENV_DIR

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

if [[ -z "${JAVA_HOME:-}" && -x /usr/bin/java ]]; then
    java_real="$(readlink -f /usr/bin/java 2>/dev/null || true)"

    if [[ "$java_real" == */bin/java ]]; then
        JAVA_HOME="${java_real:h:h}"
        export JAVA_HOME
    fi

    unset java_real
fi

if [[ -n "${JAVA_HOME:-}" && -d "$JAVA_HOME/bin" ]]; then
    zsh_path_prepend "$JAVA_HOME/bin"
fi

if [[ -d "$HOME/android-sdk/platform-tools" ]]; then
    ANDROID_HOME="$HOME/android-sdk"
elif [[ -d /usr/lib/android-sdk/platform-tools ]]; then
    ANDROID_HOME="/usr/lib/android-sdk"
else
    unset ANDROID_HOME
fi

_dotfiles_select_latest_versioned_dir() {
    local pattern="$1"
    local prefix="$2"
    local dir
    local version
    local candidate
    local best_version=""
    local best_dir=""

    autoload -Uz is-at-least

    for dir in ${~pattern}(N); do
        candidate="${dir:t}"
        version="${candidate#"$prefix"}"

        if [[ "$version" != <->(|.<->|.<->) ]]; then
            continue
        fi

        if [[ -z "$best_version" ]] || is-at-least "$version" "$best_version"; then
            best_version="$version"
            best_dir="$dir"
        fi
    done

    if [[ -n "$best_dir" ]]; then
        print -r -- "$best_dir"
    fi

    unfunction is-at-least 2>/dev/null || true
}

if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
    export ANDROID_HOME
    export ANDROID_SDK_ROOT="$ANDROID_HOME"

    zsh_path_prepend "$ANDROID_HOME/platform-tools"

    if [[ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]]; then
        zsh_path_prepend "$ANDROID_HOME/cmdline-tools/latest/bin"
    fi

    gradle_dir="$(_dotfiles_select_latest_versioned_dir "$HOME/gradle-*" "gradle-")"

    if [[ -n "$gradle_dir" && -d "$gradle_dir/bin" ]]; then
        zsh_path_prepend "$gradle_dir/bin"
    fi

    build_tools_dir="$(_dotfiles_select_latest_versioned_dir "$ANDROID_HOME/build-tools/*" "")"

    if [[ -n "$build_tools_dir" ]]; then
        zsh_path_prepend "$build_tools_dir"
    fi

    unset gradle_dir build_tools_dir
fi

unset -f _dotfiles_select_latest_versioned_dir

typeset -U path PATH
zsh_path_normalize
export PATH
