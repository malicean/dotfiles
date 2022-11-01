# Nushell Environment Config File

let-env STARSHIP_SHELL = "nu"

def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

# Use nushell functions to define your right and left prompt
let-env PROMPT_COMMAND = { create_left_prompt }
let-env PROMPT_COMMAND_RIGHT = ""

# The prompt indicators are environmental variables that represent
# the state of the prompt
let-env PROMPT_INDICATOR = ""
let-env PROMPT_INDICATOR_VI_INSERT = ": "
let-env PROMPT_INDICATOR_VI_NORMAL = "〉"
let-env PROMPT_MULTILINE_INDICATOR = "::: "

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
let-env ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand -n }
    to_string: { |v| $v | path expand -n | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
let-env NU_LIB_DIRS = [
    ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
let-env NU_PLUGIN_DIRS = [
    ($nu.config-path | path dirname | path join 'plugins')
]

# Set XDG directories for use later
load-env {
    "XDG_DATA_HOME": $"($env.HOME)/.local/share",
    "XDG_CONFIG_HOME": $"($env.HOME)/.config",
    "XDG_STATE_HOME": $"($env.HOME)/.local/state",
    "XDG_CACHE_HOME": $"($env.HOME)/.cache"
    "XDG_DESKTOP_DIR": $env.HOME
}

# Use helix as text editor
load-env {
    "EDITOR": "helix",
    "VISUAL": "helix"
}


load-env {
    "CARGO_HOME": $"($env.XDG_DATA_HOME)/cargo",
    "CUDA_CACHE_PATH": $"($env.XDG_CACHE_HOME)/nv",
    "GNUPGHOME": $"($env.XDG_DATA_HOME)/gnupg",
    "IPYTHONDIR": $"($env.XDG_CONFIG_HOME)/ipython",
    "LESSHISTFILE": $"($env.XDG_CACHE_HOME)/less/history",
    "PYTHONSTARTUP": "/etc/python/pythonrc"
    "RUSTUP_HOME": $"($env.XDG_DATA_HOME)/rustup"
}

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
let-env PATH = ($env.PATH | split row (char esep) | prepend $"($env.CARGO_HOME)/bin")

alias wget = wget $"--hsts-file=($env.XDG_DATA_HOME)/wget-hsts"
alias tig = git $"--git-dir=($env.HOME)/.dotfiles/" $"--work-tree=($env.HOME)"