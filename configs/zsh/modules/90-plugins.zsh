if [[ -z "${DOTFILES_ZSH_AUTOSUGGESTIONS_LOADED:-}" ]]; then
    if [[ -r /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
        source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        typeset -g DOTFILES_ZSH_AUTOSUGGESTIONS_LOADED=1
    elif [[ -r /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
        source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
        typeset -g DOTFILES_ZSH_AUTOSUGGESTIONS_LOADED=1
    elif [[ -r /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
        source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
        typeset -g DOTFILES_ZSH_AUTOSUGGESTIONS_LOADED=1
    fi
fi

if [[ -z "${DOTFILES_ZSH_SYNTAX_HIGHLIGHTING_LOADED:-}" ]]; then
    if [[ -r /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        typeset -g DOTFILES_ZSH_SYNTAX_HIGHLIGHTING_LOADED=1
    elif [[ -r /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        typeset -g DOTFILES_ZSH_SYNTAX_HIGHLIGHTING_LOADED=1
    elif [[ -r /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
        source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        typeset -g DOTFILES_ZSH_SYNTAX_HIGHLIGHTING_LOADED=1
    fi
fi
