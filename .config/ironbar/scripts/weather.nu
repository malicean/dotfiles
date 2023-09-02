#! /usr/bin/env nu

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