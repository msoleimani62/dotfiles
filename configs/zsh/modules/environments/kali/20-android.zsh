if [[ -d "$HOME/android-sdk/platform-tools" ]]; then
    ANDROID_HOME="$HOME/android-sdk"
elif [[ -d /usr/lib/android-sdk/platform-tools ]]; then
    ANDROID_HOME="/usr/lib/android-sdk"
else
    unset ANDROID_HOME
fi

if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
    export ANDROID_HOME
    export ANDROID_SDK_ROOT="$ANDROID_HOME"

    zsh_path_prepend "$ANDROID_HOME/platform-tools"

    if [[ -d "$ANDROID_HOME/cmdline-tools/latest/bin" ]]; then
        zsh_path_prepend "$ANDROID_HOME/cmdline-tools/latest/bin"
    fi

    if [[ -d "$ANDROID_HOME/build-tools" ]]; then
        build_tools_dir="$(
            zsh_path_latest_versioned_dir "$ANDROID_HOME/build-tools/*" ""
        )"

        if [[ -n "$build_tools_dir" ]]; then
            zsh_path_prepend "$build_tools_dir"
        fi

        unset build_tools_dir
    fi
fi
