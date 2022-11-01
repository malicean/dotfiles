source ~/.config/secrets
export OPENWEATHERMAP_API_KEY OPENWEATHERMAP_CITY_ID

export XDG_DATA_HOME=$HOME/.local/share
export XDG_CONFIG_HOME=$HOME/.config
export XDG_STATE_HOME=$HOME/.local/state
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DESKTOP_DIR=$HOME

export CUDA_CACHE_PATH=$XDG_CACHE_HOME/nv
export _JAVA_OPTIONS=-Djava.util.prefs.userRoot="$XDG_CONFIG_HOME"/java
