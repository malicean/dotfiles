# Provides the name and description of each package installed which is not a dependency
export def packages [
  # Whether to include only packages which were explicitly installed
  explicit: bool = false
] {
  let info = if $explicit {
    pacman -Qiet
  } else {
    pacman -Qit
  }
  
  $info | parse -r 'Name\s*: (?<name>.+)\n(?:.|\n)*?Description\s*: (?<desc>.+)\n'
}
