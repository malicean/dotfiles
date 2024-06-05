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

# Finds the non-negative remainder when dividing an integer by a divisor
#
# Signatures:
# <int> | math rem <int> -> <int>
export def rem [
  divisor: int # A non-negative integer to divide the input by
] {
  if $divisor < 1 {
    error make {
      msg: "divisors less than 1 are unsupported",
      label: {
        text: $"($divisor) < 1",
        span: (metadata $divisor).span
      }
    }
  }

  let r = $in mod $divisor
  
  if $r < 0 {
    $r + $divisor
  } else {
    $r
  }
}

# Performs fast modulus exponentiation
#
# Signatures:
# <int> | math rem-pow <int> <int> -> <list>
export def rem-pow [
  pow: int # The power to raise the input to
  mod: int # The modulus to compute the power within
] {
  let n = $in


  if $mod < 1 {
    error make {
      message: "modulus must be at least 1"
    }
  } else if $mod == 1 {
    0
  } else {
    if $pow < 0 {
      error make {
        message: "cannot raise to negative powers"
      }
    } else if $pow == 0 {
      1
    } else if $pow == 1 {
      $n mod $mod
    } else {
      let pow2_len = $pow | math log 2 | math floor

      # $pows2.i = $n ** (2 ** $i) mod $mod
      mut pows2 = ([($n mod $mod)] | append 2..$pow2_len)

      for i in 2..$pow2_len {
        let prev = $pows2 | get ($i - 1)
        let cur = ($prev ** 2) mod $mod
    
        $pows2 = ($pows2 | upsert $i $cur)
      }

      mut acc = 1
      mut left = $pow

      while $left > 0 {
        let left_lg2 = $left | math log 2 | math floor

        $left -= 2 ** $left_lg2
        $acc = ($acc * ($pows2 | get $left_lg2) mod $mod)
      }

      $acc
    }
  }
}

# Creates a table T such that `$T | get $x | get $y` is $x ** $y reduced-mod,
# for $x,$y in reduced-mod.
# This function computes the table more efficiently than filling each cell
# with `math rem-pow`.
#
# Signature
# math rem-pow-table <int> -> <list<list>>
export def rem-pow-table [
  mod: int
] {
  let xs = 0..($mod - 1)
  let xs2 = 2..($mod - 1)

  let id = [
    ($xs | each { 0 })
    ($xs | each { 1 })
  ]

  let mult_non_id = $xs2 | par-each --keep-order { |a|
    $xs | par-each --keep-order { |b|
      $a * $b mod $mod
    }
  }

  # Multiplication table
  # $mult.x.y = x * y mod $mod
  let mult = $id | append $mult_non_id
  
  let pow_non_id = $xs2 | par-each --keep-order { |k|
    $xs2 | reduce --fold [1 $k] { |pow, pows|
      # x^(a+b) = x^a * x^b, so use that to our advantage

      # Find suitable a,b
      let a = $pow / 2 | math floor
      let b = $pow - $a

      # Reuse old calculations to get x^a,x^b mod $mod
      let k_a = $pows | get $a
      let k_b = $pows | get $b

      # Find x^(a+b) mod $mod
      let k_pow = $mult | get $k_a | get $k_b

      $pows | append $k_pow
    }
  }

  $id | append $pow_non_id
}
