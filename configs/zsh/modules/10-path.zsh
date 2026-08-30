# Shared executable search path

typeset -U path PATH

zsh_path_prepend() {
    local dir
    local -a prepend_dirs

    prepend_dirs=()

    for dir in "$@"; do
        [[ -d "$dir" ]] || continue
        prepend_dirs+=("$dir")
    done

    path=("${prepend_dirs[@]}" "${path[@]}")
}

zsh_path_append() {
    local dir

    for dir in "$@"; do
        [[ -d "$dir" ]] || continue
        path+=("$dir")
    done
}

zsh_path_remove() {
    local dir target
    local -a filtered

    for target in "$@"; do
        filtered=()

        for dir in "${path[@]}"; do
            [[ "$dir" == "$target" ]] && continue
            filtered+=("$dir")
        done

        path=("${filtered[@]}")
    done
}

zsh_path_normalize() {
    local dir
    local -a normalized
    typeset -A seen

    normalized=()
    seen=()

    for dir in "${path[@]}"; do
        [[ -n "$dir" ]] || continue
        [[ -n "${seen[$dir]:-}" ]] && continue
        seen[$dir]=1
        normalized+=("$dir")
    done

    path=("${normalized[@]}")
}

zsh_path_prepend \
    "$HOME/.local/bin" \
    "$HOME/.local/share/nvim/mason/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.deno/bin" \
    "$HOME/go/bin" \
    "$HOME/bin"

zsh_path_normalize
export PATH
