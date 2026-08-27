# Shared executable search path

typeset -U path PATH

zsh_path_prepend() {
    local dir

    for dir in "$@"; do
        [[ -d "$dir" ]] || continue
        path=("$dir" "${path[@]}")
    done
}

zsh_path_append() {
    local dir

    for dir in "$@"; do
        [[ -d "$dir" ]] || continue
        path+=("$dir")
    done
}

zsh_path_prepend \
    "$HOME/.local/bin" \
    "$HOME/.local/share/nvim/mason/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.deno/bin" \
    "$HOME/go/bin" \
    "$HOME/bin"

export PATH
