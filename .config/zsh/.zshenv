skip_global_compinit=1

# XDG environment variables (so I can use them in scripts without having to declare edge cases all the time)
export XDG_DATA_HOME="$HOME"/.local/share
export XDG_CONFIG_HOME="$HOME"/.config
export XDG_STATE_HOME="$HOME"/.local/state
export XDG_CACHE_HOME="$HOME"/.cache

# XDG Ninja: move files OUT of my gosh darn home directory
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export CUDA_CACHE_PATH="$XDG_CACHEE_HOME"/nv
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export HISTFILE="$XDG_STATE_HOME"/zsh/history
export IPYTHONDIR="$XDG_CONFIG_HOME"/ipython
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export PYTHONSTARTUP=/etc/python/pythonrc
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export ZSH="$XDG_DATA_HOME"/oh-my-zsh
export ZSH_COMPDUMP="$XDG_CACHE_HOME"/zsh/zcompdump

## Paths
export GOPATH="$HOME/.go"
export PATH="$PATH:$HOME/.local/bin:$CARGO_HOME/bin:$GOPATH/bin"

## Editors
export EDITOR="$CARGO_HOME"/bin/hx
export SUDO_EDITOR="$EDITOR"
export VISUAL="$EDITOR"
