export def list [] {
  fc-list
    | lines
    | par-each { |line| 
      let split = ($line
        | split row ':'
        | par-each { str trim })

      let names = ($split.1 | split row ',')
      let styles = if ($split | length) > 2 {
        $split.2
          | str substring 6..
          | split row ','
          | par-each { split row ' ' }
          | flatten
      } else {
        []
      }

      {path: $split.0, names: $names, styles: $styles}
    }
}
