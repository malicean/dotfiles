# XDG Ninja
alias nvidia-settings=nvidia-settings --config="$XDG_CONFIG_HOME"/nvidia/settings
alias wget=wget --hsts-file="$XDG_DATA_HOME"/wget-hsts

# Defaults
alias spotdl='spotdl --download-threads "$(nproc)" --search-threads "$(nproc)"'
