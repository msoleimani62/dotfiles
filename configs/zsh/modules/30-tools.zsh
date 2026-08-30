if command -v zoxide >/dev/null 2>&1; then
    if ! typeset -f __zoxide_z >/dev/null 2>&1; then
        eval "$(zoxide init zsh)"
    fi
fi

if command -v fzf >/dev/null 2>&1; then
    if ! typeset -f fzf-file-widget >/dev/null 2>&1; then
        source <(fzf --zsh) 2>/dev/null || true
    fi
fi

if command -v starship >/dev/null 2>&1; then
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"

    if ! typeset -f _starship_precmd >/dev/null 2>&1; then
        eval "$(starship init zsh)"
    fi
fi

if command -v yazi >/dev/null 2>&1 && ! typeset -f ya >/dev/null 2>&1; then
    function ya() {
        if [[ $# -gt 0 && "$1" == "pkg" && -x "$HOME/.local/bin/ya" ]]; then
            command "$HOME/.local/bin/ya" "$@"
            return $?
        fi

        local tmp
        local cwd
        local yazi_status

        tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return 1

        command yazi "$@" --cwd-file="$tmp"
        yazi_status=$?

        if [[ -r "$tmp" ]]; then
            cwd="$(command cat -- "$tmp")"

            if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
                builtin cd -- "$cwd" || {
                    rm -f -- "$tmp"
                    return 1
                }
            fi
        fi

        rm -f -- "$tmp"

        return "$yazi_status"
    }
fi
