# =============================================================================
# Shared command aliases
# میانبرهای مشترک دستورات
# =============================================================================

if command -v eza >/dev/null 2>&1; then
    alias ls="eza --icons"
    alias ll="eza -la --icons --git"
    alias lt="eza --tree --icons"
else
    alias ls="ls --color=auto"
    alias ll="ls -la --color=auto"
fi

if command -v bat >/dev/null 2>&1; then
    alias cat="bat --paging=never"
elif command -v batcat >/dev/null 2>&1; then
    alias cat="batcat --paging=never"
fi

alias grep="grep --color=auto"
alias vim="nvim"
alias vi="nvim"

alias gs="git status"
alias gp="git push"
alias ga="git add"
alias gc="git commit"
alias gd="git diff"

if command -v lazygit >/dev/null 2>&1; then
    alias gl="lazygit"
fi

alias py="python3"
alias venv="python3 -m venv"
alias activate="source venv/bin/activate"

alias ..="cd .."
alias ...="cd ../.."
alias cls="clear"
alias c="clear"
