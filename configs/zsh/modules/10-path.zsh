# Shared executable search path
# مسیر جستجوی مشترک برای اجرای فایل‌های باینری

typeset -gU path PATH

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
    local target dir
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

zsh_path_latest_versioned_dir() {
    local pattern="$1"
    local prefix="$2"
    local dir
    local version
    local candidate
    local best_version=""
    local best_dir=""

    setopt local_options extended_glob

    for dir in ${~pattern}(N); do
        candidate="${dir:t}"
        version="${candidate#"$prefix"}"

        if [[ "$version" != <->(|.<->|.<->.<->) ]]; then
            continue
        fi

        if [[ -z "$best_version" ]] || _zsh_path_version_gte "$version" "$best_version"; then
            best_version="$version"
            best_dir="$dir"
        fi
    done

    if [[ -n "$best_dir" ]]; then
        print -r -- "$best_dir"
    fi
}

# مقایسه‌ی عددی دو نسخه‌ی نقطه‌جدا (مثل 34.0.0 در برابر 33.0.1)، تکه به تکه،
# بدون وابستگی به تابع بیرونی is-at-least که با autoload از fpath لود می‌شود
# و در یک zsh غیرتعاملی (مثل bats یا CI) ممکن است اصلاً پیدا نشود.
# 10# جلوی هر تکه از تفسیر اشتباه به‌عنوان عدد octal (مثل "08") جلوگیری می‌کند.
#
# Numeric, component-by-component comparison of two dot-separated versions
# (e.g. 34.0.0 vs 33.0.1), without depending on the external is-at-least
# function, which is autoloaded from fpath and may not be found at all in a
# non-interactive zsh (like bats or CI). The 10# prefix on each component
# prevents zsh from misreading a leading-zero segment (like "08") as octal.
_zsh_path_version_gte() {
    local -a left right
    local i l r

    left=("${(s:.:)1}")
    right=("${(s:.:)2}")

    for (( i = 1; i <= ${#left} || i <= ${#right}; i++ )); do
        l="${left[i]:-0}"
        r="${right[i]:-0}"

        if (( 10#$l > 10#$r )); then
            return 0
        elif (( 10#$l < 10#$r )); then
            return 1
        fi
    done

    return 0
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
