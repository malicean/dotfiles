# Calculates the factorial of a number
#
# Signatures:
# <int> | math fac -> <int>
export def fac [] {
  let to = $in

  if $to == 0 {
    1
  } else {
    1..$to | math product
  }
}

# Calculates the number of permutations from a given set size
#
# Signatures:
# <int> | math perm <int> -> <int>
export def perm [
  choose: int
] {
  let set = $in
  
  if $choose == 0 {
    1
  } else {
    # A naive approach would be:
    # ($set | fac) / (($set - $choose) | fac)
    # However, given that a! = 1..a | math product and a! / b! = b..a | math product,
    # we can calculate the numerator and denominator and then do a smart calculation

    ($set - $choose)..$set | skip 1 | math product
  }
}

# Calculates the number of combinations from a given set size
#
# Signatures:
# <int> | math perm <int> -> <int>
export def comb [
  choose: int
] {
  let set = $in

  ($set | perm $choose) / ($choose | fac)
}