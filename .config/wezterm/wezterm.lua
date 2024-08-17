local wezterm = require 'wezterm'

return {
  color_scheme = 'Shapeshifter (light) (terminal.sexy)',
  colors = {
    visual_bell = '#ff8080'
  },

  font = wezterm.font 'FiraCode Nerd Font',
  font_size = 16,

  visual_bell = {
    fade_in_function = 'EaseIn',
    fade_in_duration_ms = 150,
    fade_out_function = 'EaseOut',
    fade_out_duration_ms = 150,    
  },

  window_decorations = 'RESIZE',
  window_background_opacity = 0.98,
  enable_tab_bar = false,
}
