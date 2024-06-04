# Calculates the factorial of a number
#
# Signatures:
# <int> | math fac -> <int>
export def fac [] {
  let to = $in

  if $to == 0 {
    1
  } else {
    1..$to | each {||} | math product
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

    ($set - $choose)..$set | each {||} | skip 1 | math product
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

export def reduce-mod [
  modulus: int
] {
  if $modulus < 2 {
    error make {
      msg: "moduluses less than 2 are unsupported",
      label: {
        text: $"($modulus) < 2",
        span: (metadata $modulus).span
      }
    }
  }

  let r = $in mod $modulus
  
  if $r < 0 {
    $r + $modulus
  } else {
    $r
  }
}

# INTRINSIC:
# x < y
def gcd-presort [
  x: int,
  y: int
] {
  let r = $y mod $x

  if $r == 0 {
    $x
  } else {
    gcd-presort $r $x
  }
}

# Calculates the greatest common denominator between two integers
#
# Signatures:
# math gcd <int> <int> -> <int>
export def gcd [
  a: int,
  b: int
] {
  let sort = [$a $b] | sort
  gcd-presort $sort.0 $sort.1
}

# Calculates how many integers are below and relatively prime to the current integer
#
# Signatures:
# <int> | math phi -> <int>
export def phi [] {
  let n = $in

  if $n == 0 or $n == 1 {
    0
  } else {
    (2..($n - 1)
    | filter { |i| (gcd-presort $i $n) == 1 }
    | length) + 1
    
  }
}

# Creates a list T where the ith entry equals ($in ** (2 ** i)) mod $mod, for all i s.t. 2 ** i <= p
#
# Signatures:
# <int> | math n-pow2 <int> <int> -> <list>
def n-pow2 [
  p: int,
  mod: int
] {
  let n = $in
  let p_lg = ($p | math log 2) | math floor
  mut n_pow2 = [1 ($n mod $mod)] | append 3..$p_lg

  for i in 2..$p_lg {
    let prev = $n_pow2 | get ($i - 1)
    let cur = ($prev ** 2) mod $mod
    
    $n_pow2 = ($n_pow2 | upsert $i $cur)
  }

  $n_pow2
}

export def rem-pow [
  p: int,
  mod: int
] {
  let n = $in

  if $mod < 2 {
    error make {
      message: "modulus must be at least 2"
    }
  }

  if $p < 0 {
    error make {
      message: "cannot raise to negative powers"
    }
  } else if $p == 0 {
    1
  } else if $p == 1 {
    $n mod $p
  } else {
    let n_pow2 = $n | n-pow2 $p $mod

    mut ret = 1
    mut left = $p

    while $left > 0 {
      let left_lg2 = $left | math log 2 | math floor

      $left -= 2 ** $left_lg2
      $ret *= (($n_pow2 | get $left_lg2) mod $mod)
    }

    $ret
  }
}
