# =============================================================================
# Distribution-independent Zsh plugins
# پلاگین‌های Zsh مستقل از توزیع لینوکس
# =============================================================================

zsh_load_first_existing() {
    local candidate

    for candidate in "$@"; do
        if [[ -f "$candidate" ]]; then
            source "$candidate"
            return 0
        fi
    done

    return 1
}

zsh_load_first_existing \
    /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
    /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

zsh_load_first_existing \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

unset -f zsh_load_first_existing
