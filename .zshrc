# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
HIST_STAMPS="dd.mm.yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  autoupdate
  git
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
)

# Autocompletion support
# Must be performed before compinit, which happens in oh-my-zsh.sh sourcing below
zfunc="$HOME/.zfunc"
mkdir -p "$zfunc"
fpath+="$zfunc"

rustup completions zsh > "$zfunc/_rustup"

# Stores the compdump in a cache folder, rather than the home directory (WHY IS THIS THE DEFAULT)
ZSH_COMPDUMP="${XDG_CACHE_HOME}/zsh/zcompdump"
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Alternatively, preferred editor for both local and remote sessions
export EDITOR='helix'
export VISUAL="$EDITOR"

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# GPG WSL fix
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# Use GPG as SSH auth
unset SSH_AGENT_PID
if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
  export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
fi

# Startup some CLI fancy-fication
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# Dotfiles
# https://www.atlassian.com/git/tutorials/dotfiles
alias tig='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Possibly local-but-sometimes-not binaries
OLD_IFS=$IFS
IFS=':'
OLD_SHWORDSPLIT=$options[shwordsplit]
setopt shwordsplit

for tuple in \
  'hx:helix:' \
  'spotdl:spotdl:--download-threads "$(nproc)" --search-threads "$(nproc)"'
do
    set -- $tuple
    name=$1
    basename=$2
    args=$3
    
    for stem in '/usr/bin' '/usr/local/bin' "$HOME/.cargo/bin"; do
      invoke="$stem/$basename"
      
       if [ -f "$invoke" ]; then
        if [ ! -z "$args" ]; then
          invoke+=" $args"
        fi
        
        alias $name="$invoke"
        break
      fi
    done
    
    if [ -z "$invoke" ]; then
      echo Could not find absolute path to "$name" ("$basename")
    fi
done

options[shwordsplit]=$OLD_SHWORDSPLIT
IFS=$OLD_IFS