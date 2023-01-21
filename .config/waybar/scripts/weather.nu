#! /bin/nu

use wttr.nu

let info = (wttr fetch)
let now = $info.now

let glither = ($now.weather.code | wttr glither)
let desc = $now.weather.desc
let temp = $now.temp.c
let wind = $now.wind.kmph

{
  text: ([`﨎 ` $temp `° /   ` $wind ` / ` $glither] | str join),
  class: `weather`
} | to json --raw