# =============================================================================
# Interactive command-line tools
# ابزارهای تعاملی خط فرمان
# =============================================================================

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh) 2>/dev/null || true
fi

if command -v starship >/dev/null 2>&1; then
    export STARSHIP_CONFIG="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
    eval "$(starship init zsh)"
fi

if command -v yazi >/dev/null 2>&1; then
    function ya() {
        local tmp
        local cwd

        tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return 1

        command yazi "$@" --cwd-file="$tmp"

        if [[ -r "$tmp" ]]; then
            cwd="$(command cat -- "$tmp")"
            if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
                builtin cd -- "$cwd"
            fi
        fi

        rm -f -- "$tmp"
    }
fi
