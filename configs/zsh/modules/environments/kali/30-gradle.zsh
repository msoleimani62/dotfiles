if [[ -n "${ANDROID_HOME:-}" && -d "$ANDROID_HOME" ]]; then
    gradle_dir="$(
        zsh_path_latest_versioned_dir "$HOME/gradle-*" "gradle-"
    )"

    if [[ -n "$gradle_dir" && -d "$gradle_dir/bin" ]]; then
        zsh_path_prepend "$gradle_dir/bin"
    fi

    unset gradle_dir
fi
