def "into setrise" [
  object: string
] {
  let time = $in

  if $time =~ $"No ($object)\(set|rise)" {
    null
  } else {
    $time | into datetime
  }
}

# Fetches current weather data from https://wttr.in and structures it
# 
# Signatures:
# <nothing> | fetch -> record
export def fetch [] {
  let raw = (curl -s `https://wttr.in/?format=j1` | from json)

  let days = ($raw.weather | each { |day|
    let date = ($day.date | into datetime)
    let ast = $day.astronomy.0
    
    {
      date: $date,
      temp: {
        c: ($day.mintempC | into int)..($day.maxtempC | into int),
        f: ($day.mintempF | into int)..($day.maxtempF | into int)
      },
      astro: {
        sun: {
          rise: ($ast.sunrise | into setrise `sun`), 
          set: ($ast.sunset | into setrise `sun`)
        },
        moon: {
          rise: ($ast.moonrise | into setrise `moon`),
          set: ($ast.moonset | into setrise `moon`),
          phase: $ast.moon_phase,
          lum: $ast.moon_illumination
        }
      },
      hourly: ($day.hourly | each { |hour|
        let time = ($hour.time | into int)
      
        {
          time: ($date + ($time // 100 * 1hr) + ($time mod 100 * 1min)),
          weather: {
            code: $hour.weatherCode,
            desc: $hour.weatherDesc
          }
          temp: {
            real: {
              c: $hour.tempC,
              f: $hour.tempF
            },
            feel: {
              c: $hour.FeelsLikeC,
              f: $hour.FeelsLikeF
            }
          },
          wind: {
            km: $hour.windspeedKmph,
            mi: $hour.windspeedMiles
          },
          pressure: {
            mbar: $hour.pressure,
            inhg: $hour.pressureInches
          },
          precip: {
            mm: $hour.precipMM,
            in: $hour.precipInches
          },
          humidity: $hour.humidity
        }
      })
    }
  })
  
  let now = $raw.current_condition.0
  {
    now: {
      weather: {
        code: $now.weatherCode,
        desc: $now.weatherDesc.0.value
      }
      temp: {
        real: {
          c: $now.temp_C,
          f: $now.temp_F
        },
        feel: {
          c: $now.FeelsLikeC
          f: $now.FeelsLikeF
        }
      },
      wind: {
        kmph: $now.windspeedKmph,
        mph: $now.windspeedMiles
      },
      pressure: {
        mbar: $now.pressure,
        inhg: $now.pressureInches
      },
      precip: {
        mm: $now.precipMM,
        in: $now.precipInches
      },
      humidity: $now.humidity
    },
    days: $days
  }
}

# Converts a weather code to Glither text.
# Glither is a glyph-based weather conlang.
# For more information about weather codes, see https://www.worldweatheronline.com/weather-api/api/docs/weather-icons.aspx
#
# Signatures
# int | icon -> string
export def glither [] {
  let name = ($in | into string)
  let icons = {
    113: "  ",
    116: "  ",
    119: "  ",
    122: "  ",
    143: "  ",
    176: "  ",
    179: "  ",
    182: "  ",
    185: "  ",
    200: "  ",
    227: "  ",
    230: " ﰕ ",
    248: "  ",
    260: "  ",
    263: "  ",
    266: "  ",
    281: "  ",
    284: "  ",
    293: "  ",
    296: "  ",
    299: "  ",
    302: "  ",
    305: "  ",
    308: "  ",
    311: "  ",
    314: "  ",
    317: "  ",
    320: "  ",
    323: "  ",
    326: "  ",
    329: " ﰕ ",
    332: " ﰕ ",
    335: " ﰕ ",
    338: " ﰕ ",
    350: "  ",
    353: "  ",
    356: "  ",
    359: "  ",
    362: "  ",
    365: "  ",
    368: "  ",
    371: " ﰕ ",
    374: "  ",
    377: "  ",
    386: "  ",
    389: "  ",
    392: " ﰕ ",
    395: " ﰕ ",
  }  
  
  $icons | get $name
}
