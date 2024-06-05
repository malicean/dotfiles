def rga [
  replace: string,
  parse: string,
  pattern: string,
] {
  run-external 'rga' '--multiline' '--follow' $"--replace=($replace)" $pattern
  | lines
  | parse --regex $parse
  | upsert name { path parse | get stem }
  | upsert page { into int }
}

export def main [] {
  [ (appearance) (weight) (melting) (density) (boiling) (formula) ]
  | reverse
  | each { reject page }
  | reduce { |lhs,rhs| $lhs | join $rhs name }
  | sort-by name
}

# Generates a table containing the names of each compound (according to file), its appearance (form and color), and the page on which the appearance was found.
export def appearance [] {
  rga '$1:$2:$3' '(?<name>[^:]+):(?<page>\d+):(?<form>.+):(?<color>.*)' 'Page (\d+): Appearance\n(?:Page \d+: \n)*Page \d: Form(?:: |\n(?:Page \d+: \n)*Page \d+: )(.+)(?:\n(?:Page \d+: \n)*Page \d+: Colou?r(?:: |\n(?:Page \d+: \n)*Page \d+: )(.+))?'
  | move page --after color
}

export def weight [] {
  rga '$1:$2' '(?<name>[^:]+):(?<page>\d+):(?<weight>.+)' 'Page (\d+): Molecular [Ww]eight\n(?:Page \d+: .*\n)*Page \d+: [^\d\n]*(\d+(?:[\.,]\d+)) g\/mol.*'
  | move page --after weight
}

export def melting [] {
  rga '$1:$2:$3' '(?<name>[^:]+):(?<page>\d+):(?<melt_C>.*):(?<melt_F>.*)' 'Page (\d+): Melting point\/range: (.+) °C (?:\((.+) °F\)).+'
  | move page --after melt_F
}

export def density [] {
  rga '$1:$2' '(?<name>[^:]+):(?<page>\d+):(?<density>.*)' 'Page (\d+): .*[Dd]ensity\n(?:Page \d+: .*\n)*?Page \d+: [^\d\n]*(\d+(?:[\.,]\d+)) g\/(?:cm3|mL).+'
  | move page --after density
}

export def boiling [] {
  rga '$1:$2:$3' '(?<name>[^:]+):(?<page>\d+):(?<boil_C>.*):(?<boil_F>.*)' 'Page (\d+): .*[Bb]oiling point.*\n(?:Page \d+: .*\n)*?Page \d+: [^\d\n]*(.+) °C(?: \(?(.+) °F)?.*'
  | move page --after boil_F
}

export def formula [] {
  rga '$1:$2' '(?<name>[^:]+):(?<page>\d+):(?<formula>.+)' 'Page (\d+): Formula\nPage \d+: Molecular [Ww]eight\n(?:Page \d+: .*\n)*Page \d: [^A-Z]*(.+)\nPage \d+: [^\d\n]*\d+(?:[\.,]\d+) g\/mol.*'
}
