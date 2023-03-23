export def main [
  --spacer (-s): any
] {
  let l2 = $in

  let length = ($l2 | last | length)
  do {
    let neq = ($l2 | drop | any { |l| ($l | length) != $length })

    if $neq {
      let span = (metadata $l2).span
      
      error make {
        msg: "mismatched list lengths",
        label: {
          text: "lists contained here",
          start: $span.start,
          end: $span.end
        }
      }
    }
  }

  0..($length - 1) | each { |i|
    $l2
      | each { |l1|
        let ith = ($l1 | get $i)

        if $spacer == null {
          [$ith]
        } else {
          [$ith $spacer]
        }
      } 
      | flatten 
      | drop
  }
}
