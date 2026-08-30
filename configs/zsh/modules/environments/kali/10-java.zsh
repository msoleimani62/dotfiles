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
