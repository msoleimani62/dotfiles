# Kali NetHunter phone environment

ZSH_ENV_FILE="${${(%):-%N}:A}"
ZSH_ENV_DIR="${ZSH_ENV_FILE:h}"

source "$ZSH_ENV_DIR/../modules/loader.zsh" || return 1

unset ZSH_ENV_FILE ZSH_ENV_DIR

alias update="sudo apt update && sudo apt upgrade"

if [[ -f "$HOME/.deno/env" ]]; then
    source "$HOME/.deno/env"
fi

export UV_LINK_MODE="${UV_LINK_MODE:-copy}"
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

path=(${path:#$PYENV_ROOT/shims})
path=(${path:#$PYENV_ROOT/plugins/pyenv-virtualenv/shims})

if [[ -x "$PYENV_ROOT/bin/pyenv" ]]; then
    zsh_path_prepend "$PYENV_ROOT/bin"
fi

if [[ -d /usr/lib/jvm/java-21-openjdk-arm64 ]]; then
    export JAVA_HOME="${JAVA_HOME:-/usr/lib/jvm/java-21-openjdk-arm64}"
    zsh_path_prepend "$JAVA_HOME/bin"
fi

if [[ -d /usr/lib/android-sdk ]]; then
    export ANDROID_HOME="${ANDROID_HOME:-/usr/lib/android-sdk}"
elif [[ -d "$HOME/android-sdk" ]]; then
    export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
fi

if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
    export ANDROID_SDK_ROOT="$ANDROID_HOME"

    zsh_path_prepend \
        "$ANDROID_HOME/platform-tools" \
        "$ANDROID_HOME/cmdline-tools/latest/bin" \
        "$HOME/gradle-8.7/bin"

    zsh_add_latest_android_build_tools() {
        local build_tools_dir
        local newest_build_tools

        [[ -d "$ANDROID_HOME/build-tools" ]] || return 0

        build_tools_dir=("$ANDROID_HOME"/build-tools/*(/N))

        (( ${#build_tools_dir[@]} > 0 )) || return 0

        newest_build_tools="$(
            printf '%s\n' "${build_tools_dir[@]}" |
                sort -V |
                tail -n1
        )"

        [[ -n "$newest_build_tools" ]] || return 0

        zsh_path_prepend "$newest_build_tools"
    }

    zsh_add_latest_android_build_tools
    unset -f zsh_add_latest_android_build_tools
fi

export PATH
