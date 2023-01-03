local wezterm = require 'wezterm'

return {
  font = wezterm.font 'FiraCode Nerd Font',
  font_size = 18.0,
  
  color_scheme = "Monokai (base16)",
  window_background_opacity = 0.8,
  
  enable_tab_bar = false,
  window_padding = {
    left = 1,
    right = 1
  },
  window_close_confirmation = 'NeverPrompt'
}