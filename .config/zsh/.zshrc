# GPG as SSH
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

# Autocompletion support
## Must be performed before compinit, which happens when oh-my-zsh.sh is sourced below
zfunc="$XDG_STATE_HOME"/zfunc
fpath=($fpath "$zfunc")

rustup completions zsh > "$zfunc"/_rustup
# packwiz completion zsh > "$zfunc/_packwiz"

# Oh My Zsh
ZSH_THEME="robbyrussell"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="dd.mm.yyyy"

plugins=(
  autoupdate
  git
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

source "$ZSH"/oh-my-zsh.sh

# CLI fancy-fication
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# Aliases

## Dotfiles
### https://www.atlassian.com/git/tutorials/dotfiles
alias tig='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

## Helpful
alias rc='hx "$ZSHDOTDIR"/.zshrc'
alias py='ipython3'