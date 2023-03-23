#! /bin/nu

# TODO: add case for yesterday (at midnight, data becomes [yesterday today tomorrow] rather than [today tomorrow overmorrow])

use wttr.nu
use stack.nu

def setrise [] { 
  let time = $in

  if $time == null {
    " none"
  } else {
    $time | date format "%H:%M"
  }
}
# Padding shortcut
def spad [length: int] { into string | fill --alignment Left --width $length --character ' ' }
# Triple pads (for temperatures)
def trip [] { spad 3 }
# Double pads (for winds)
def doup [] { spad 2 }

# Converts hourly weather data into a summary line
#
# Signatures:
# <record> | hourly <bool> -> list<str>
def hourly [
  is_now: bool  # Indicates that this hourly report is currently occuring
] {
  let data = $in
  
  let point = if $is_now {
    "󱀝"
  } else {
    " "
  }
  let time = ($data.time | date format "%H:%M")
  let temp = ($data.temp.real.c | trip)
  let wind = ($data.wind.km | doup)

  [$point " " $time " | 﨎 " $temp "° |   " $wind " | " ($data.weather.code | wttr glither)]
}

# Converts daily weather data into a summary page
#
# Signatures:
# <record> | daily -> list<str> 
def daily [] {
  let data = $in

  let until = ($data.date - (date now))
  let is_today = $until < 0hr
  
  let title = do {
    let informal = if $is_today {
      "Today"
    } else if $until < 24hr {
      "Morrow"
    } else if $until < 48hr {
      "Overmorrow"
    } else {
      null
    }
    
    $data.date
      | date format `%d %b`
      | if $informal == null {
        $in
      } else {
        prepend [$informal `, `]
      }
  }

  let hourly = do {
    let closure = if $is_today {
      let now_index = do { 
        $data.hourly
          | each { |h| (date now) - $h.time }
          | enumerate
          | filter { |p| $p.item > 0sec }
          | sort-by item
          | get 0.index
      }

      { |h| $h.item | hourly ($h.index == $now_index) }
    } else {
      { |h| $h.item | hourly false }
    }
    

    $data.hourly | enumerate | each $closure
  }

  [
    [""]
    (["<b>" $title "</b>" ("" | spad 19)] | flatten)
    ["󱩱 " ($data.temp.c | first | spad 5) "°            󱣗 " ($data.temp.c | last | spad 5) "°     "]
    ["󱑌 " ($data.astro.sun.rise | setrise) "             󱑌 " ($data.astro.sun.set | setrise) "      "]
    [" " ($data.astro.moon.rise | setrise) "              " ($data.astro.moon.set | setrise) "      " ]
    [" " ($data.astro.moon.phase | fill --alignment Right --width 15 --character " ") "   󱟇 " ($data.astro.moon.lum | spad 5) "%     "]
  ] 
    | append $hourly
}


def text [] {
  let now = $in.now

  let glither = ($now.weather.code | wttr glither)
  let temp = $now.temp.real.c
  let wind = $now.wind.kmph
    
  $"﨎 ($temp)° /   ($wind) / ($glither)"
}

def tooltip [] {
  let info = $in

  let header = ([
    ["<b>" $info.now.weather.desc "</b>\n"]
    ["Feels like: " $info.now.temp.feel.c "°\n"]
    ["Humidity: " $info.now.humidity "%\n"]
  ]
    | each { prepend "\t\t" }
    | flatten)

  let days = ($info.days
    | last 2
    | each { daily }
    | stack --spacer "    "
    | each { append "\n" }
    | flatten
    | prepend ($info.days.0 | daily | each { prepend "\t\t" | append "\n" })
    | flatten)

  [
    $header
    $days
  ]
    | flatten
    | str join
}

let wttr = wttr fetch

{
  text: ($wttr | text),
  tooltip: ($wttr | tooltip)
}
  | to json --raw