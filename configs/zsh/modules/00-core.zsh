# =============================================================================
# Core interactive Zsh configuration
# تنظیمات هسته و عمومی Zsh
# =============================================================================

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${HISTFILE:-$HOME/.zsh_history}"

setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt HIST_VERIFY

export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"

typeset -gU path PATH
