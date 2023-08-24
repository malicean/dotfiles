#! /usr/bin/env nu

# TODO: add case for yesterday (at midnight, data becomes [yesterday today tomorrow] rather than [today tomorrow overmorrow])

use ~/.config/nushell/scripts/wttr.nu

def text [] {
  let now = $in.now

  let glither = ($now.weather.code | wttr glither)
  let temp = $now.temp.real.c
  let wind = $now.wind.kmph
    
  $"󰔏 ($temp)° /   ($wind) / ($glither)"
}

let wttr = (wttr fetch)

$wttr | text