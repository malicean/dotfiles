export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DESKTOP_DIR=$HOME

export EDITOR=helix
export VISUAL=helix
export SUDOEDITOR=helix
export TERMINAL=kitty

export CARGO_HOME="$XDG_DATA_HOME"/cargo
export IPYTHONDIR="$XDG_CONFIG_HOME"/ipython
export HISTFILE="$XDG_STATE_HOME"/bash/history
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export PYTHONSTARTUP=/etc/python/pythonrc
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export WINEPREFIX="$XDG_DATA_HOME"/wine
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export GOPATH="$XDG_DATA_HOME"/go
export ERRFILE="$XDG_CACHE_HOME"/X11/xsession-errors
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java

export PATH="$PATH":"$CARGO_HOME"/bin:"$HOME"/.local/bin
export MPD_HOST="$HOME"/.local/state/mpd/socket
