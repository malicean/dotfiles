export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DESKTOP_DIR=$HOME

export EDITOR=helix
export VISUAL=helix
export SUDOEDITOR=helix
export TERMINAL=kitty
export BROWSER=firefox

export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export CUDA_CACHE_PATH="$XDG_CACHE_HOME"/nv
export DOTNET_CLI_HOME="$XDG_DATA_HOME"/dotnet
export ERRFILE="$XDG_CACHE_HOME"/X11/xsession-errors
export GOPATH="$XDG_DATA_HOME"/go
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GRC_PREFS_PATH="$XDG_CONFIG_HOME"/gnuradio/grc.conf
export HISTFILE="$XDG_STATE_HOME"/bash/history
export IPYTHONDIR="$XDG_CONFIG_HOME"/ipython
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export NUGET_PACKAGES="$XDG_CACHE_HOME"/NuGetPackages
export OMNISHARPHOME="$XDG_CONFIG_HOME"/omnisharp
export OPAMROOT="$XDG_DATA_HOME"/opam
export PARALLEL_HOME="$XDG_CONFIG_HOME"/parallel
export PYTHONSTARTUP=/etc/python/pythonrc
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export WINEPREFIX="$XDG_DATA_HOME"/wine

export PATH="$PATH":"$CARGO_HOME"/bin:"$HOME"/.local/bin
export MPD_HOST="$HOME"/.local/state/mpd/socket

alias np=ncmpcpp
alias npb='np --host 100.79.210.95' # plane tailscale IP
alias t='kitty --detach'
alias r=ranger

test -r /home/malicean/.local/share/opam/opam-init/init.sh && . /home/malicean/.local/share/opam/opam-init/init.sh > /dev/null 2> /dev/null || true
