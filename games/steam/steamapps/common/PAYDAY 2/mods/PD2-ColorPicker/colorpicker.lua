--todo fix not updating gradient_s position when selecting hue slider when color is white
--todo dragged color preview
--todo fix click clbk activating when releasing held mouse on another object (make own click clbk call; check mouse obj against released)
--visually block right-side blt menu to indicate noninteractability?
--change mouse color when dragging?
--set eyedropper position when calling setup()
--fix pointer image on mouseover event

ColorPicker = ColorPicker or blt_class()
ColorPicker.queued_items = {}
function ColorPicker.CreateQueuedMenus()
	if #ColorPicker.queued_items > 0 then 
		for i,_data in pairs(ColorPicker.queued_items) do 
			local data = table.remove(ColorPicker.queued_items,i)
			local result = ColorPicker.init(_data.obj,unpack(_data.arguments))
			if result and type(data.callback) == "function" then 
				obj.init_done = true
				data.callback(result)
			end
		end
	end
end

local leftclick = Idstring("0")
local rightclick = Idstring("1")

ColorPicker.current_menu = nil
ColorPicker.mouse0_held = false
ColorPicker.mouse1_held = false
function ColorPicker:init(id,parameters,create_cb,...)
	self.init_done = false
	if not managers.gui_data then 
		if type(create_cb) == "function" then 
			--queue creation
			table.insert(ColorPicker.queued_items,{callback = create_cb,arguments = {id,parameters,create_cb,...},obj=self})
			return self
		else
			log("[ColorPicker] WARNING: New ColorPicker menu \"" .. tostring(id) .. "\" created, but managers.gui_data is not yet set up! Please make sure to check for .init_done flag before performing operations with this ColorPicker menu!")
			return self
		end
	end
	self.init_done = true
	ColorPicker._WS = ColorPicker._WS or managers.gui_data:create_fullscreen_workspace()
	
	local instance_name = "ColorPicker" .. tostring(id)
	Hooks:Register(instance_name)
	
	self._panel = ColorPicker._WS:panel():panel({
		name = instance_name,
		layer = 999,
		visible = false
	})
	
	self._blur_bg = self._panel:bitmap({
		name = "blur_bg",
		color = Color.white,
		layer = -1,
		w = self._panel:w(),
		h = self._panel:h(),
		texture = "guis/textures/test_blur_df",
		texture_rect = nil,
		render_template = "VertexColorTexturedBlur3D"
	})
	
	self._instance_name = instance_name
	self._name = id
	self._active = false
	self._moused_object_name = nil
	self.held_color = nil
	
	--these are mostly used to cache the most recent calculations for these values
	--the final color is stored separately as a built color
	self.hue = 0
	self.value = 0
	self.saturation = 0
	
	self.previous_color = Color.white --the default, or "before" color. returned along with palettes if cancel button is clicked
	self.current_color = Color.white --your new color, or "after" color. returned along with palettes if accept button is clicked
	
	--todo different colorspaces?
		--list of interactable ui objects
			--callbacks:
				--UNUSED get_color: when the color of this object is requested, returns the result of this function
				--drop_color: when a color is dragged (and released) onto this object, performs this function, with the color as the first argument
				--on_leftdrag: when leftclick is pressed over this object and held, performs this function once
				--leftdoubleclick: when leftclick is quickly pressed twice over this object, performs this function
				--rightdoubleclick: when rightclick is quickly pressed twice over this object, performs this function
				--leftclick: when leftclick is quick pressed and released over this object, performs this function, with x and y as the first two arguments
				--rightclick: when rightclick is quickly pressed and released over this object, performs this function, with x and y as the first two arguments
				--leftdrag: while leftclick is pressed over this object and held (even if the mouse leaves the object), performs this function, with x and y as the first two arguments
				--mouseover: when this object is moused over, performs this function, with x/y as the first two arguments, and object as the third argument
				--mouseover_end: when this object was moused over but then another object is moused over, performs this function, with x/y as the first two arguments, and object as the third argument
	self._mouseover_objects = {
		gamut_box_bg = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_gamut_box"),
			callbacks = {
				get_color = callback(self,self,"get_current_color"),
				leftdoubleclick = nil,
				rightdoubleclick = nil,
--				leftclick = callback(self,self,"update_gamut_box_position"), --check current color; disabled because of the bug where releasing mouse over an object counts as a click
				rightclick = nil,
				leftdrag = callback(self,self,"update_gamut_box_position"),
				on_leftdrag = callback(self,self,"set_pointer_image","none"),
				drop_color = function(color)
					self:set_current_color(color,true)
					self:check_eyedropper_position()
				end,
				mouseover = callback(self,self,"set_pointer_image","link"),
				mouseover_end = nil
			}
		}, --main color field
		hue_slider_bg = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_hue_slider"),
			callbacks = {
				get_color = nil,
				leftdoubleclick = nil,
				rightdoubleclick = nil,
				leftclick = nil,
				rightclick = nil,
				leftdrag = callback(self,self,"update_hue_slider"),
				on_leftdrag = callback(self,self,"set_pointer_image","grab"),
				drop_color = nil,
				mouseover = callback(self,self,"set_pointer_image","hand"),
				mouseover_end = nil
			}
		},
		preview_previous_box = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_select_previous"),
			callbacks = {
				get_color = callback(self,self,"get_previous_color"),
				leftdoubleclick = nil,
				rightdoubleclick = nil,
				leftclick = function()
					self:set_current_color(self:get_previous_color())
				end,
				rightclick = nil,
				leftdrag = nil,
				on_leftdrag = function()
				--set current held to get_current_color
					self:set_held_color(self:get_previous_color())
					self:set_pointer_image("grab")
				end,
				on_leftdrag = callback(self,self,"set_pointer_image","grab"),
				drop_color = nil,
				mouseover = callback(self,self,"set_pointer_image","link"),
				mouseover_end = nil
			}
		},
		preview_current_box = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_select_current"),
			callbacks = {
				get_color = callback(self,self,"get_current_color"),
				leftdoubleclick = nil,
				rightdoubleclick = nil,
				leftclick = nil,
				rightclick = nil,
				leftdrag = nil,
				on_leftdrag = function()
					self:set_held_color(self:get_current_color())
					self:set_pointer_image("grab")
				end, --set held color to current color
				drop_color = function(color) 
					self:set_current_color(color)
					self:check_eyedropper_position()
				end,
				mouseover = nil,
				mouseover_end = nil
			}
		},
		hex_box = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_hex"),
			callbacks = {
				get_color = callback(self,self,"get_current_color"),
				leftdoubleclick = function()
					self:copy_current_color()
					self:set_tooltip(managers.localization:text("menu_colorpicker_notif_copied"))
				end,
				rightdoubleclick = nil,
				leftclick = nil,
				rightclick = callback(self,self,"paste_to_current_color"),
				leftdrag = nil,
				on_leftdrag = function()
					self:set_held_color(self:get_current_color())
					self:set_pointer_image("grab")
				end, --set held color to current color
				drop_color = function(color)
					self:get_current_color(color)
					self:check_eyedropper_position()
				end,
				mouseover = callback(self,self,"set_pointer_image","link"),
				mouseover_end = nil
			}
		},
		reset_palette_button_box = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_reset_palettes"),
			callbacks = {
				leftdoubleclick = function()
					self:reset_palettes()
					self:set_tooltip(managers.localization:text("menu_colorpicker_notif_reset_palettes_success"))
				end,
				rightdoubleclick = nil,
				leftclick = nil,
				rightclick = nil,
				leftdrag = nil,
				on_leftdrag = nil,
				drop_color = nil,
				mouseover = function(x,y,o)
					self:set_pointer_image("link")
					o:set_alpha(0.5)
				end,
				mouseover_end = function(x,y,o)
					o:set_alpha(1)
				end
			}
		},
		accept_button_box = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_close_accept"),
			callbacks = {
				get_color = nil,
				leftclick = callback(self,self,"Hide",true,true), --return current color/do select callback with current color, and exit
				rightdoubleclick = nil,
				leftdoubleclick = nil,
				rightclick = nil,
				leftdrag = nil,
				drop_color = nil,
				mouseover = function(x,y,o) 
					--highlight box to indicate interact-ability
					self:set_pointer_image("link")
					o:set_alpha(0.5)
				end,
				mouseover_end = function(x,y,o)
					o:set_alpha(1)
				end
			}
		},
		cancel_button_box = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_close_cancel"),
			callbacks = {
				get_color = nil,
				leftclick = callback(self,self,"Hide",false,true), --return previous color/do select callback with previous color, and exit
				rightdoubleclick = nil,
				leftdoubleclick = nil,
				rightclick = nil,
				leftdrag = nil,
				drop_color = nil,
				mouseover = function(x,y,o) 
					--highlight box to indicate interact-ability
					self:set_pointer_image("link")
					o:set_alpha(0.5)
				end,
				mouseover_end = function(x,y,o)
					o:set_alpha(1)
				end
			}
		}
		--palette data is generated at the time of palette bitmaps generation
	}
	self._mouseover_objects.hue_slider_cursor = self._mouseover_objects.hue_slider --hue slider and hue slider arrow should essentially be treated as the same object, interaction wise

	self.parameters = { --placement data
		gamut_box_size = 300,
		gamut_box_x = 100,
		gamut_box_y = 100,
		
		hue_slider_x = 420,
		hue_slider_y = 100,
		hue_slider_w = 25,
		hue_slider_h = 300,
		
		hue_slider_cursor_w = 12,
		hue_slider_cursor_h = 12,
		hue_slider_cursor_texture = tweak_data.hud_icons.wp_arrow.texture,
		hue_slider_cursor_texture_rect = tweak_data.hud_icons.wp_arrow.texture_rect,
		hue_slider_cursor_color = Color.white,
		
		eyedropper_circle_w = nil, --use default icon size
		eyedropper_circle_h = nil,
		eyedropper_circle_texture = tweak_data.hud_icons.pd2_kill.texture,
		eyedropper_circle_texture_rect = tweak_data.hud_icons.pd2_kill.texture_rect,
		eyedropper_circle_color = Color.white,
		
		preview_previous_box_x = 500,
		preview_previous_box_y = 100,
		preview_previous_box_w = 72,
		preview_previous_box_h = 72,
		preview_previous_label_font = "fonts/font_medium_shadow_mf",
		preview_previous_label_font_size = 24,
		preview_previous_label_color = Color(0.5,0.5,0.5),
		preview_previous_label_text = "Previous",
		
		preview_current_box_x = 500,
		preview_current_box_y = 172,
		preview_current_box_w = 72,
		preview_current_box_h = 72,
		preview_current_label_font = "fonts/font_medium_shadow_mf",
		preview_current_label_font_size = 24,
		preview_current_label_color = Color(0.5,0.5,0.5),
		preview_current_label_text = "Current",
		
		hex_box_x = 500,
		hex_box_y = 250,
		hex_box_w = 72,
		hex_box_h = 24,
		hex_box_color = Color(0.3,0.3,0.3),
		hex_label_font_size = 16,
		hex_label_font = tweak_data.hud.medium_font,
		hex_label_color = Color.white,
		
		accept_button_box_x = 500,
		accept_button_box_y = 600,
		accept_button_box_w = 100,
		accept_button_box_h = 24,
		accept_button_box_color = Color("5B8554"),
		accept_button_label_text = "[A] Accept",
		accept_button_label_font = tweak_data.hud.medium_font,
		accept_button_label_font_size = 16,
		accept_button_label_color = Color.white,
		
		cancel_button_box_x = 500,
		cancel_button_box_y = 625,
		cancel_button_box_w = 100,
		cancel_button_box_h = 24,
		cancel_button_box_color = Color("7a7a7a"),
		cancel_button_label_text = "[C] Cancel",
		cancel_button_label_font = tweak_data.hud.medium_font,
		cancel_button_label_font_size = 16,
		cancel_button_label_color = Color.white,
		
		reset_palette_button_box_x = 600,
		reset_palette_button_box_y = 250,
		reset_palette_button_box_w = 100,
		reset_palette_button_box_h = 24,
		reset_palette_button_box_color = Color("131313"),
		
		reset_palette_button_label_text = "Reset Palettes",
		reset_palette_button_label_font = tweak_data.hud.medium_font,
		reset_palette_button_label_font_size = 16,
		reset_palette_button_label_color = Color(0.7,0.7,0.7),
		
		palette_box_size = 24,
		palette_box_start_x = 600,
		palette_box_start_y = 100,
		palette_box_spacing = 6,
		
		tooltip_label_text = "",
		tooltip_label_font = tweak_data.hud.medium_font,
		tooltip_label_font_size = 16,
		tooltip_label_font_color = Color.white,
		tooltip_label_margin = 4,
		
		tooltip_box_x = 0,
		tooltip_box_y = 600,
		tooltip_box_w = 400,
		tooltip_box_h = 100,
		tooltip_box_color = Color(0.2,0.2,0.2),
		
		title_label_text = "ColorPicker 1.0",
		title_label_font = tweak_data.hud.medium_font,
		title_label_font_size = 16,
		title_label_font_color = Color.white,
		
		title_box_x = 0,
		title_box_y = 1000,
		title_box_w = 300,
		title_box_h = 50,
		title_box_color = Color(0.5,0.5,0.5),
		
--		blur_bg_w = 1280, --optional parameters, nil by default so as to inherit parent panel traits
--		blur_bg_h = 720,
--		blur_bg_x = 0,
--		blur_bg_y = 0,
		blur_bg_alpha = 1, --visible by default, hidden if true
		blur_bg_texture = "guis/textures/test_blur_df",
		blur_bg_texture_rect = nil, --should be a table containing four number values
		
		default_palettes = {
			Color(1,0,0),
			Color(1,0.5,0),
			Color(1,1,0),
			Color(0.5,1,0),
			Color(0,1,0),
			
			Color(0,1,0.5),
			Color(0,1,1),
			Color(0,0.5,1),
			Color(0,0,1),
			Color(0.5,0,1),
			
			Color(1,0,1),
			Color(1,0,0.5),
			Color(0,0,0),
			Color(1/3,1/3,1/3),
			Color(2/3,2/3,2/3),
			
			Color(0.1,0.1,0.1),
			Color(0.3,0.3,0.3),
			Color(0.5,0.5,0.5),
			Color(0.7,0.7,0.7),
			Color(0.9,0.9,0.9),
			
			Color(0.2,0.2,0.2),
			Color(0.4,0.4,0.4),
			Color(0.6,0.6,0.6),
			Color(0.8,0.8,0.8),
			Color(1,1,1),
		},
		
		palette_rows = 5,
		palette_columns = 5,
	}
	self.parameters.palettes = table.deep_map_copy(self.parameters.default_palettes)
	self.num_palettes = self.parameters.palette_rows * self.parameters.palette_columns
		
	
--[[
	local size = 500
	self._size = size
	local color_preview_box_size = 100
	local preview_previous_box_x = size / 20
	local preview_previous_box_y = size / 20
	local preview_new_box_x = preview_previous_box_x
	local preview_new_box_y = preview_previous_box_y + color_preview_box_size
	
	local slider_w = size / 20
	local slider_handle_w = 8
	local slider_handle_h = 8 -- math.max(1,size / 100)
	local slider_x = 30
	local slider_y = 0

	local palette_x = size * 1.15
	local palette_y = size * 0.8
	local palette_size = size / 20
	local palette_spacing = size / 75
	
	local hex_label_x = size
	local hex_label_y = size
	local label_font_size = size / 40
	
	local button_font_size = size / 40
	local accept_button_text_x = size * 1.2
	local accept_button_text_y = size
	local accept_button_box_w  = size / 15
	local accept_button_box_h  = size / 30
	local accept_button_box_x  = size * 1.2
	local accept_button_box_y  = size
	
	local cancel_button_text_x = size * 1.2
	local cancel_button_text_y = size
	local cancel_button_box_w  = size / 15
	local cancel_button_box_h  = size / 30
	local cancel_button_box_x  = size * 1.2
	local cancel_button_box_y  = accept_button_box_y + (accept_button_box_h * 1.1)
	
	local tooltip_box_x = size
	local tooltip_box_y = size
	local tooltip_box_w = size / 10
	local tooltip_box_h = size / 25
	local tooltip_text_font_size = size / 40
	
	local title_text_x = 100
	local title_text_y = 100
	--]]
	
	local p = self.parameters
	local gradient_v = self._panel:gradient({
		name = "gradient_v",
		rotation = 90,
		layer = 3,
		alpha = 1,
		x = p.gamut_box_x,
		y = p.gamut_box_y,
		w = p.gamut_box_size,
		h = p.gamut_box_size,
		blend_mode = "normal",
		gradient_points = {
			0,
			Color.black:with_alpha(0),
			1,
			Color.black
		}
	})
	local gradient_s = self._panel:gradient({
		name = "gradient_s",
		layer = 2,
		alpha = 1,
		x = p.gamut_box_x,
		y = p.gamut_box_y,
		w = p.gamut_box_size,
		h = p.gamut_box_size,
		blend_mode = "normal",
		gradient_points = {
			0,
			Color.red:with_alpha(0),
			1,
			Color.red
		}
	})
	
	local eyedropper_circle = self._panel:bitmap({
		name = "eyedropper_circle",
		layer = 4,
		x = -42069,
		y = -42069,
		color = p.eyedropper_circle_color,
		w = p.eyedropper_circle_w,
		h = p.eyedropper_circle_h,
		texture = p.eyedropper_circle_texture,
		texture_rect = p.eyedropper_circle_texture_rect,
	})
	
	local gamut_box_bg = self._panel:rect({ --also acts as the "hitbox" 
		name = "gamut_box_bg",
		layer = 1,
		color = Color.white,
		x = p.gamut_box_x,
		y = p.gamut_box_y,
		w = p.gamut_box_size,
		h = p.gamut_box_size,
		blend_mode = "normal"
	})
	
	local hue_slider_colors = { --create hue slider gradient
		Color(1,0,0),
		Color(1,1,0),
		Color(0,1,0),
		Color(0,1,1),
		Color(0,0,1),
		Color(1,0,1),
		Color(1,0,0)
	}
	local hue_slider_points = {}
	for index,color in pairs(hue_slider_colors) do 
		table.insert(hue_slider_points,#hue_slider_points + 1,(index - 1)/(#hue_slider_colors - 1)) --num
		table.insert(hue_slider_points,#hue_slider_points + 1,hue_slider_colors[index]) --color
	end
	
	local hue_slider = self._panel:gradient({
		name = "hue_slider",
		layer = 4,
		rotation = 90,
		x = p.hue_slider_x + p.hue_slider_w + - ((p.hue_slider_h + p.hue_slider_w) / 2),
		y = p.hue_slider_y + ((p.hue_slider_h - p.hue_slider_w) / 2),
		w = p.hue_slider_h,
		h = p.hue_slider_w,
		blend_mode = "normal",
		gradient_points = hue_slider_points,
	})
	local hue_slider_bg = self._panel:rect({
		name = "hue_slider_bg",
		layer = 1,
		color = Color.black,
		x = p.hue_slider_x,
		y = p.hue_slider_y,
		w = p.hue_slider_w,
		h = p.hue_slider_h,
		blend_mode = "normal"
	})
	local hue_slider_cursor = self._panel:bitmap({
		name = "hue_slider_cursor",
		layer = 5,
		texture = p.hue_slider_cursor_texture,
		texture_rect = p.hue_slider_cursor_texture_rect,
		color = p.hue_slider_cursor_color,
		rotation = 180,
		w = p.hue_slider_cursor_w,
		h = p.hue_slider_cursor_h,
		x = hue_slider_bg:x() + p.hue_slider_w,
		y = hue_slider_bg:y(), --doesn't matter since it's changed on hue slider changed callback
		blend_mode = "normal"
	})

	local preview_previous_box = self._panel:rect({
		name = "preview_previous_box",
		layer = 6,
		color = self.previous_color,
		w = p.preview_previous_box_w,
		h = p.preview_previous_box_h,
		x = p.preview_previous_box_x,
		y = p.preview_previous_box_y
	})
	
	 --this will be manually centered to avoid having to recreate it if the box size changes
	local preview_previous_label = self._panel:text({
		name = "preview_previous_label",
		text = p.preview_previous_label_text,
--		blend_mode = "sub",
		layer = 10,
		x = preview_previous_box:x(),
		y = preview_previous_box:y(),
		font = p.preview_previous_label_font,
		font_size = p.preview_previous_label_font_size,
		color = p.preview_previous_label_color
	})
	
	local preview_current_box = self._panel:rect({
		name = "preview_current_box",
		layer = 6,
		alpha = 1,
		color = self.current_color,
		w = p.preview_current_box_w,
		h = p.preview_current_box_h,
		x = p.preview_current_box_x,
		y = p.preview_current_box_y
	})
	local preview_current_label = self._panel:text({
		name = "preview_current_label",
		text = "Current",
--		blend_mode = "sub",
		layer = 10,
		x = preview_current_box:x(),
		y = preview_current_box:y(),
		font = p.preview_current_label_font,
		font_size = p.preview_current_label_font_size,
		color = p.preview_current_label_color
	})
	
	local hex_box = self._panel:rect({
		name = "hex_box",
		layer = 8,
		x = p.hex_box_x,
		y = p.hex_box_y,
		w = p.hex_box_w,
		h = p.hex_box_h,
		color = p.hex_box_color
	})
	local hex_label = self._panel:text({
		name = "hex_label",
		layer = 10,
		x = p.hex_box_x,
		y = p.hex_box_y,
		text = Color.white:to_hex(),
		font = p.hex_label_font,
		font_size = p.hex_label_font_size,
		color = p.hex_label_color
	})
	
	local reset_palette_button_box = self._panel:rect({
		name = "reset_palette_button_box",
		layer = 9,
		x = p.reset_palette_button_box_x,
		y = p.reset_palette_button_box_y,
		w = p.reset_palette_button_box_w,
		h = p.reset_palette_button_box_h,
		color = p.reset_palette_button_box_color
	})
	local reset_palette_button_label = self._panel:text({
		name = "reset_palette_button_label",
		layer = 10,
		x = p.reset_palette_button_box_x,
		y = p.reset_palette_button_box_y,
		text = p.reset_palette_button_label_text,
		font = p.reset_palette_button_label_font,
		font_size = p.reset_palette_button_label_font_size,
		color = p.reset_palette_button_label_color
	})
	self.center_text(reset_palette_button_label,reset_palette_button_box)
	
	local accept_button_box = self._panel:rect({
		name = "accept_button_box",
		layer = 9,
		x = p.accept_button_box_x,
		y = p.accept_button_box_y,
		w = p.accept_button_box_w,
		h = p.accept_button_box_h,
		color = p.accept_button_box_color
	})
	
	local accept_button_text = self._panel:text({
		name = "accept_button_text",
		layer = 10,
		x = p.accept_button_box_x,
		y = p.accept_button_box_y,
		text = p.accept_button_label_text,
		font = p.accept_button_label_font,
		font_size = p.accept_button_label_font_size,
		color = p.accept_button_label_color
	})
	local cancel_button_box = self._panel:rect({
		name = "cancel_button_box",
		layer = 9,
		x = p.cancel_button_box_x,
		y = p.cancel_button_box_y,
		w = p.cancel_button_box_w,
		h = p.cancel_button_box_h,
		color = p.cancel_button_box_color
	})
	local cancel_button_text = self._panel:text({
		name = "cancel_button_text",
		layer = 10,
		x = p.cancel_button_box_x,
		y = p.cancel_button_box_y,
		text = p.cancel_button_label_text,
		font = p.cancel_button_label_font,
		font_size = p.cancel_button_label_font_size,
		color = p.cancel_button_label_font_color
	})
	
	local title_box = self._panel:rect({
		name = "title_box",
		layer = 7,
		x = p.title_box_x,
		y = p.title_box_y,
		w = p.title_box_w,
		h = p.title_box_h,
		color = p.title_box_color
	})
	
	--manually centered
	local title_label = self._panel:text({
		name = "title_label",
		text = p.title_label_text,
		layer = 10,
		x = p.title_box_x,
		y = p.title_box_y,
		font = p.title_label_font,
		font_size = p.title_label_font_size,
		color = p.title_label_font_color
	})
	
	
	local tooltip_box = self._panel:rect({
		name = "tooltip_box",
		layer = 5,
		x = p.tooltip_box_x,
		y = p.tooltip_box_y,
		w = p.tooltip_box_w,
		h = p.tooltip_box_h,
		color = p.tooltip_box_color
	})
	
	local tooltip_label = self._panel:text({
		name = "tooltip_label",
		text = p.tooltip_label_text,
		layer = 8,
		x = p.tooltip_box_x,
		y = p.tooltip_box_y,
		font = p.tooltip_label_font,
		font_size = p.tooltip_label_font_size,
		color = p.tooltip_label_font_color
	})
	
	self:setup(parameters)
	return self
end

function ColorPicker.center_text(text,box)
	local x,y,w,h = text:text_rect()
	text:set_x(box:x() + ((box:w() - w) / 2))
	text:set_y(box:y() + ((box:h() - h) / 2))
end

function ColorPicker:setup(parameters)
	parameters = parameters or {}

--	self.current_color = parameters.color or self.current_color
	self:set_current_color(parameters.color or self.current_color)
	self.previous_color = parameters.color or self.previous_color

	local r,g,b = self.current_color:unpack()
	self.hue,self.saturation,self.value = self.get_hsvl_from_rgb(r,g,b)
	
	self._done_cb = parameters.done_callback or self._done_cb
	self._changed_cb = parameters.changed_callback or self._changed_cb
	
	if parameters.default_palettes then 
		self.parameters.default_palettes = table.deep_map_copy(parameters.default_palettes)
	end
	for i = 1,self.num_palettes,1 do 
		local palette_name = "palette_" .. tostring(i)
		local palette = self._panel:child(palette_name)
		if alive(palette) then 
			self._panel:remove(palette)
		end
		self._mouseover_objects[palette_name] = nil
	end
	local recenter_title = false
	for k,v in pairs(parameters or {}) do 
		--if k == title_box_w then recenter_title = true end
		self.parameters[k] = v --or self.parameters[k]
	end
	parameters = self.parameters
	self.num_palettes = parameters.palette_columns * parameters.palette_rows
	
	local gradient_v = self._panel:child("gradient_v")
	gradient_v:set_position(parameters.gamut_box_x,parameters.gamut_box_y)
	gradient_v:set_size(parameters.gamut_box_size,parameters.gamut_box_size)
	
	local gradient_s = self._panel:child("gradient_s")
	gradient_s:set_position(parameters.gamut_box_x,parameters.gamut_box_y)
	gradient_s:set_size(parameters.gamut_box_size,parameters.gamut_box_size)
	local h_col = Color(self.get_rgb_from_hsv(self.hue,1,1))
	gradient_s:set_gradient_points({
		0,
		h_col:with_alpha(0),
		1,
		h_col
	})
	
	--local eyedropper_circle = self._panel:child("eyedropper_circle")
	
	--set eyedropper center here
	
	local gamut_box_bg = self._panel:child("gamut_box_bg")
	gamut_box_bg:set_position(parameters.gamut_box_x,parameters.gamut_box_y)
	gamut_box_bg:set_size(parameters.gamut_box_size,parameters.gamut_box_size)
	
	local hue_slider = self._panel:child("hue_slider")
	hue_slider:set_x(parameters.hue_slider_x + parameters.hue_slider_w + - ((parameters.hue_slider_h + parameters.hue_slider_w) / 2))
	hue_slider:set_y(parameters.hue_slider_y + ((parameters.hue_slider_h - parameters.hue_slider_w) / 2))
	hue_slider:set_size(parameters.hue_slider_h,parameters.hue_slider_w) --since the slider is rotated 90*, w and h must be swapped
	
	local hue_slider_bg = self._panel:child("hue_slider_bg")
	hue_slider_bg:set_position(parameters.hue_slider_x,parameters.hue_slider_y)
	hue_slider_bg:set_size(parameters.hue_slider_w,parameters.hue_slider_h)
	
	local hue_slider_cursor = self._panel:child("hue_slider_cursor")
	hue_slider_cursor:set_image(parameters.hue_slider_cursor_texture,unpack(parameters.hue_slider_cursor_texture_rect or {}))
	hue_slider_cursor:set_size(parameters.hue_slider_cursor_w,parameters.hue_slider_cursor_h)
	hue_slider_cursor:set_x(hue_slider_bg:x() + parameters.hue_slider_w)
	
	local preview_previous_box = self._panel:child("preview_previous_box")
	preview_previous_box:set_size(parameters.preview_previous_box_w,parameters.preview_previous_box_h)
	preview_previous_box:set_position(parameters.preview_previous_box_x,parameters.preview_previous_box_y)
	preview_previous_box:set_color(self.previous_color)
	
	local preview_previous_label = self._panel:child("preview_previous_label")
	preview_previous_label:set_font(Idstring(parameters.preview_previous_label_font))
	preview_previous_label:set_font_size(parameters.preview_previous_label_font_size)
	preview_previous_label:set_color(parameters.preview_previous_label_color)
	local _x,_y,_w,_h = preview_previous_label:text_rect()
	preview_previous_label:set_x(preview_previous_box:x() + ((preview_previous_box:w() - _w) / 2))
--	preview_previous_label:set_y(preview_previous_box:y() + ((preview_previous_box:h() - _h) / 2))
	
	local preview_current_box = self._panel:child("preview_current_box")
	preview_current_box:set_size(parameters.preview_current_box_w,parameters.preview_current_box_h)
	preview_current_box:set_position(parameters.preview_current_box_x,parameters.preview_current_box_y)
	preview_current_box:set_color(self.current_color)
	
	local preview_current_label = self._panel:child("preview_current_label")
	preview_current_label:set_text(parameters.preview_current_label_text)
	preview_current_label:set_font(Idstring(parameters.preview_current_label_font))
	preview_current_label:set_font_size(parameters.preview_current_label_font_size)
	preview_current_label:set_color(parameters.preview_current_label_color)
	local _x,_y,_w,_h = preview_current_label:text_rect()
	preview_current_label:set_x(preview_current_box:x() + ((preview_current_box:w() - _w) / 2))
--	preview_current_label:set_y(preview_current_box:y() + ((preview_current_box:h() - _h) / 2))
	
	local hex_box = self._panel:child("hex_box")
	hex_box:set_position(parameters.hex_box_x,parameters.hex_box_y)
	hex_box:set_size(parameters.hex_box_w,parameters.hex_box_h)
	hex_box:set_color(parameters.hex_box_color)
	
	local hex_label = self._panel:child("hex_label")
	hex_label:set_font(Idstring(parameters.hex_label_font))
	hex_label:set_font_size(parameters.hex_label_font_size)
	hex_label:set_color(parameters.hex_label_color)
	hex_label:set_text("000000")
	self.center_text(hex_label,hex_box)
	hex_label:set_text(self.current_color:to_hex())
	
	local reset_palette_button_box = self._panel:child("reset_palette_button_box")
	reset_palette_button_box:set_position(parameters.reset_palette_button_box_x,parameters.reset_palette_button_box_y)
	reset_palette_button_box:set_size(parameters.reset_palette_button_box_w,parameters.reset_palette_button_box_h)
	reset_palette_button_box:set_color(parameters.reset_palette_button_box_color)
	
	local reset_palette_button_label = self._panel:child("reset_palette_button_label")
	reset_palette_button_label:set_font(Idstring(parameters.reset_palette_button_label_font))
	reset_palette_button_label:set_font_size(parameters.reset_palette_button_label_font_size)
	reset_palette_button_label:set_color(parameters.reset_palette_button_label_color)
	reset_palette_button_label:set_text(parameters.reset_palette_button_label_text)
	self.center_text(reset_palette_button_label,reset_palette_button_box)
	
	local accept_button_box = self._panel:child("accept_button_text")
	accept_button_box:set_position(parameters.accept_button_box_x,parameters.accept_button_box_y)
	accept_button_box:set_size(parameters.accept_button_box_w,parameters.accept_button_box_h)
	accept_button_box:set_color(parameters.accept_button_box_color)
	
	local accept_button_text = self._panel:child("accept_button_text")
	accept_button_text:set_font(Idstring(parameters.accept_button_label_font))
	accept_button_text:set_font_size(parameters.accept_button_label_font_size)
	accept_button_text:set_color(parameters.accept_button_label_color)
	accept_button_text:set_text(parameters.accept_button_label_text)
	self.center_text(accept_button_text,accept_button_box)
	
	local cancel_button_box = self._panel:child("cancel_button_box")
	cancel_button_box:set_position(parameters.cancel_button_box_x,parameters.cancel_button_box_y)
	cancel_button_box:set_size(parameters.cancel_button_box_w,parameters.cancel_button_box_h)
	cancel_button_box:set_color(parameters.cancel_button_box_color)
	
	local cancel_button_text = self._panel:child("cancel_button_text")
	cancel_button_text:set_font(Idstring(parameters.cancel_button_label_font))
	cancel_button_text:set_font_size(parameters.cancel_button_label_font_size)
	cancel_button_text:set_color(parameters.cancel_button_label_color)
	cancel_button_text:set_text(parameters.cancel_button_label_text)
	self.center_text(cancel_button_text,cancel_button_box)
	
	local title_box = self._panel:child("title_box")
	title_box:set_position(parameters.title_box_x,parameters.title_box_y)
	title_box:set_size(parameters.title_box_w,parameters.title_box_h)
	title_box:set_color(parameters.title_box_color)
	
	local tooltip_box = self._panel:child("tooltip_box")
	tooltip_box:set_position(parameters.tooltip_box_x,parameters.tooltip_box_y)
	tooltip_box:set_size(parameters.tooltip_box_w,parameters.tooltip_box_h)
	tooltip_box:set_color(parameters.tooltip_box_color)
	
	local tooltip_label = self._panel:child("tooltip_label")
	tooltip_label:set_font(Idstring(parameters.tooltip_label_font))
	tooltip_label:set_font_size(parameters.tooltip_label_font_size)
	tooltip_label:set_color(parameters.tooltip_label_font_color)
	tooltip_label:set_text(managers.localization:text("menu_colorpicker_prompt_default"))
	tooltip_label:set_position(parameters.tooltip_box_x + parameters.tooltip_label_margin,parameters.tooltip_box_y + parameters.tooltip_label_margin)
	
	local blur_bg = self._blur_bg
	blur_bg:set_image(parameters.blur_bg_texture,blur_texture_rect and unpack(blur_texture_rect))
	if parameters.blur_bg_x then 
		blur_bg:set_x(parameters.blur_bg_x)
	end
	if parameters.blur_bg_y then 
		blur_bg:set_y(parameters.blur_bg_y)
	end
	if parameters.blur_bg_w then 
		blur_bg:set_w(parameters.blur_bg_w)
	end
	if parameters.blur_bg_h then 
		blur_bg:set_h(parameters.blur_bg_h)
	end
	if parameters.blur_bg_alpha then 
		blur_bg:set_alpha(parameters.blur_bg_alpha)
	end
	
	local title_label = self._panel:child("title_label")
	title_label:set_text(parameters.title_label_text)
	title_label:set_font(Idstring(parameters.title_label_font))
	title_label:set_font_size(parameters.title_label_font_size)
	title_label:set_color(parameters.title_label_font_color)
	self.center_text(title_label,title_box)
	
	local palette_size = parameters.palette_box_size
	local palette_spacing = parameters.palette_box_spacing
	
	for i = 1,self.num_palettes,1 do 
		local j = i - 1
		
		local palette_color
		local palette_color_string = "ffffff"
		if parameters.palettes and parameters.palettes[i] then 
			palette_color_string = parameters.palettes[i]
			if type(palette_color_string) == "userdata" then 
				palette_color = parameters.palettes[i]
			end
		elseif parameters.default_palettes and parameters.default_palettes[i] then 
			palette_color_string = parameters.default_palettes[i]
			if type(palette_color_string) == "userdata" then 
				palette_color = parameters.default_palettes[i]
			end
		end
		palette_color = palette_color or Color(palette_color_string)
		
		local palette_name = "palette_" .. i
		local palette = self._panel:rect({
			name = palette_name,
			layer = 5,
			color = palette_color,
			w = palette_size,
			h = palette_size,
			x = parameters.palette_box_start_x + ((palette_size + palette_spacing) * (j % parameters.palette_columns)),
			y = parameters.palette_box_start_y + ((palette_size + palette_spacing) * math.floor(j / parameters.palette_columns))
		})
		self._mouseover_objects[palette_name] = {
			mouseover_tooltip = managers.localization:text("menu_colorpicker_prompt_palette"),
			callbacks = {
				get_color = callback(palette,palette,"color"),
				leftdoubleclick = nil,
				rightdoubleclick = nil,
				leftclick = function()
					self:set_current_color(palette:color())
					self:check_eyedropper_position()
				end,
				rightclick = function()
						palette:set_color(self:get_current_color())
					end,
				drop_color = function(color)
					palette:set_color(color)
					self:check_eyedropper_position()
				end,
				on_leftdrag = function()
					self:set_held_color(palette:color())
					self:set_pointer_image("grab")
				end,
				mouseover = function(x,y,o)
					self:set_pointer_image("link")
				end,
				mouseover_end = nil
			}
		}
	end
	
	
end

function ColorPicker:update_gamut_box_position(x,y) --clbk gamut box
	local gamut_box = self._panel:child("gamut_box_bg")
	local s_x,s_y = gamut_box:position()
	local w,h = gamut_box:size()
	local saturation = math.clamp(x-s_x,0,w)/w
	local value = 1 - (math.clamp(y-s_y,0,h)/h)
	self.saturation = saturation
	self.value = value
	self._panel:child("eyedropper_circle"):set_center(math.clamp(x,s_x,s_x+w),math.clamp(y,s_y,s_y+h))
--[[
	local chroma = saturation * value
	local hue = self.hue / 60
	local n = chroma * (1 - math.abs(hue % 2 - 1))
	local r,g,b = 0,0,0
	if self.hue <= 0 then 
		--oops! all zeroes
	elseif 0 <= hue and hue <= 1 then 
		r = chroma
		g = n
		b = 0
	elseif 1 <= hue and hue <= 2 then 
		r = n
		g = chroma
		b = 0
	elseif 2 <= hue and hue <= 3 then 
		r = 0
		g = chroma
		b = n
	elseif 3 <= hue and hue <= 4 then 
		r = 0
		g = n
		b = chroma
	elseif 4 <= hue and hue <= 5 then 
		r = n
		g = 0
		b = chroma
	elseif 5 <= hue and hue <= 6 then 
		r = chroma
		g = 0
		b = n
	end
	local xm = value - chroma
	r = r + xm
	g = g + xm
	b = b + xm
	--]]
	local r,g,b = self.get_rgb_from_hsv(self.hue,saturation,value)
	self:set_current_color(Color(r,g,b),true)
	--create color from s/v and use as selected color
end

function ColorPicker:update_hue_slider(x,y) --clbk hue slider
	local slider = self._panel:child("hue_slider_bg")
	local s_x,s_y = slider:position()
--	local y = _y + s_y
	local h = slider:h()
	
	local hue = 360 * math.clamp(y-s_y,0,h)/h
	self:set_hue(hue,true)
	local hue_slider_cursor = self._panel:child("hue_slider_cursor")
	hue_slider_cursor:set_y(math.clamp(y, s_y, s_y + h) - (hue_slider_cursor:h() / 2))
end

function ColorPicker:Show(parameters)
	if not self.init_done then 
		return
	end
	if parameters then 
		--only realign things if parameters is given
		self:setup(parameters)
	end
	
	if ColorPicker.current_menu and self._name ~= ColorPicker.current_menu:get_name() then 
		ColorPicker.current_menu:Hide(nil,false)
	end
	ColorPicker.current_menu = self
	self._panel:show()
	if not self._active then
		ColorPicker._WS:connect_keyboard(Input:keyboard())
		self._panel:key_press(callback(self,self,"key_press")) --todo fix this (nonfunctional for unknown reasons)
		managers.mouse_pointer:use_mouse({
		mouse_move = callback(self, self, "on_mouse_moved"),
		mouse_click = callback(self, self, "on_mouse_clicked"),
		mouse_press = callback(self, self, "on_mouse_pressed"),
		mouse_double_click = callback(self, self, "on_mouse_doubleclicked"),
		mouse_release = callback(self, self, "on_mouse_released"),
		id = "colorpicker"
	})
		game_state_machine:_set_controller_enabled(false)
		self._active = true
		
		if managers.menu and managers.menu:active_menu() and managers.menu:active_menu().renderer then 
			managers.menu:active_menu().renderer:disable_input(math.huge)
		end
	end
end

function ColorPicker:Hide(accepted,do_cb)
	if self._active then 
--		if self._moused_object_name then 
--			local moused_object_data = self._mouseover_objects[self._moused_object_name]
--			if moused_object_data and moused_object_data.callbacks.mouseover_end then 
--				moused_object_data.callbacks.mouseover_end(0,0,self._panel:child(self._moused_object_name))
--			end
--		end
		managers.mouse_pointer:remove_mouse("colorpicker")
		game_state_machine:_set_controller_enabled(true)
		ColorPicker._WS:disconnect_keyboard()
		self._panel:key_press(nil)
		self._active = false
		if do_cb then 
			if accepted then 
				local color,palettes = self:get_current_color(),self:get_palettes()
				if type(self._done_cb) == "function" then 
					self._done_cb(color,palettes,accepted)
				end
				Hooks:Call("ColorPicker" .. self._name,color,palettes)
			else
				local color,palettes = self:get_previous_color(),self:get_palettes()
				if type(self._done_cb) == "function" then 
					self._done_cb(color,palettes,false)
				end
				Hooks:Call("ColorPicker" .. self._name,color,palettes)
			end
		end
		if managers.menu and managers.menu:active_menu() and managers.menu:active_menu().renderer then 
			managers.menu:active_menu().renderer:disable_input(0.1)
		end
	end
	self._panel:hide()
end

function ColorPicker:set_pointer_image(icon)
	if icon == "none" then 
		managers.mouse_pointer._mouse:child("pointer"):hide()
	else
		managers.mouse_pointer._mouse:child("pointer"):show()
		managers.mouse_pointer:set_pointer_image(icon)
	end
--	managers.mouse_pointer:set_pointer_image("grab") --arrow (cursor arrow), link (pointer hand). hand (open hand), grab (closed hand)
end

function ColorPicker:set_held_color(color)
	self.held_color = color
end

function ColorPicker:get_held_color()
	return self.held_color
end

function ColorPicker:get_name()
	return self._name
end

function ColorPicker:active()
	return self._active
end

function ColorPicker:set_palette_color(color,index)
	local palette = self._panel and self._panel:child("palette_" .. tostring(index))
	if palette then 
		return palette:color()
	end
end

function ColorPicker:get_palette_color(index) --not used anywhere
	local palette = self._panel and self._panel:child("palette_" .. tostring(index))
	if palette then 
		return palette:color()
	end
end

function ColorPicker.get_hsvl_from_rgb(r,g,b)
	local value = math.max(r,g,b)
	local xm = math.min(r,g,b)
	local chroma = value-xm
	local hue = 0
	if chroma == 0 then 
		hue = 0
	elseif value == r then
		hue = 60 * (0 + ((g-b)/chroma))
	elseif value == g then
		hue = 60 * (2 + ((b-r)/chroma))
	elseif value == b then 
		hue = 60 * (4 + ((r-g)/chroma))
	end
	local saturation = 0
	if value == 0 then 
		return 0,0,0,0
	else
		saturation = chroma/value
	end
	local lightness = (value + xm) / 2
	return ((hue - 1) % 360) + 1,saturation,value,lightness
end

function ColorPicker.get_rgb_from_hsv(_hue,saturation,value)
	local chroma = value * saturation
	local r,g,b
	if not _hue or (_hue <= 0) then 
		--oops! all zeroes
		return 0,0,0
	else
		local hue = math.clamp(_hue,0,360) / 60
		local n = chroma * (1 - math.abs((hue % 2) - 1))
		if 0 <= hue and hue <= 1 then 
			r = chroma
			g = n
			b = 0
		elseif 1 <= hue and hue <= 2 then 
			r = n
			g = chroma
			b = 0
		elseif 2 <= hue and hue <= 3 then 
			r = 0
			g = chroma
			b = n
		elseif 3 <= hue and hue <= 4 then 
			r = 0
			g = n
			b = chroma
		elseif 4 <= hue and hue <= 5 then 
			r = n
			g = 0
			b = chroma
		elseif 5 <= hue and hue <= 6 then 
			r = chroma
			g = 0
			b = n
		else --dead code
			log("[ColorPicker] Error! hue exceeded expected bounds: " .. tostring(hue))
			r = 0
			g = 0
			b = 0
		end
	end
	local m = value - chroma
	r = r + m
	g = g + m
	b = b + m
	return r,g,b
end

function ColorPicker.get_rgb_from_hue(hue) --should not be used
	return (1+math.cos(hue))/2,(1+math.cos(hue+240))/2,(1+math.cos(hue+120))/2
end

function ColorPicker.get_hue_from_rgb(r,g,b)
	return ( (math.atan2(math.sqrt(3) * (g - b),2 * (r - g - b)) - 1) % 360) + 1
end

function ColorPicker:set_hue(hue,from_slider)
	if hue == 0 then 
		hue = 360
	end
	self.hue = hue
	local color = Color(self.get_rgb_from_hsv(hue,1,1))
	self._panel:child("gradient_s"):set_gradient_points({
		0,
		color:with_alpha(0),
		1,
		color
	})
	
	if not from_slider then 
		local slider = self._panel:child("hue_slider_bg")
		local s_x,s_y = slider:position()
		local h = slider:h()
		local hue_slider_cursor = self._panel:child("hue_slider_cursor")
		hue_slider_cursor:set_y(s_y + (h * hue/360) - (hue_slider_cursor:h() / 2))
	else
		self:set_current_color(Color(self.get_rgb_from_hsv(self.hue,self.saturation,self.value)),from_slider)
	end
end

function ColorPicker:check_hue_slider_position()
	--really it's more like setting the slider's position according to color
	
	local slider = self._panel:child("hue_slider_bg")
	local slider_cursor = self._panel:child("hue_slider_cursor")
	local s_x,s_y = slider:position()
	local h = slider:h()
	slider_cursor:set_y(s_y + math.clamp(h * self.hue/360,0,h) - (slider_cursor:h() / 2))
end

function ColorPicker:set_preview_current_color(color)
	self._panel:child("preview_current_box"):set_color(color)
end

function ColorPicker:set_tooltip(id)
	self._panel:child("tooltip_label"):set_text(id)
end

function ColorPicker:set_hex_label(color)
	self._panel:child("hex_label"):set_text(color:to_hex())
end

function ColorPicker:get_current_color()
	return self.current_color
end

function ColorPicker:set_current_color(color,skip_check_hue,skip_changed_clbk)
	self.current_color = color
	self:set_preview_current_color(color)
	self:set_hex_label(color)
	
	if not skip_changed_clbk and type(self._changed_cb) == "function" then 
		self._changed_cb(color)
	end
	
	if not skip_check_hue then 
		local hue,saturation,value = self.get_hsvl_from_rgb(color:unpack())
		self:set_hue(hue)
		self:set_value(value)
		self:set_saturation(saturation)
		self:check_hue_slider_position()
		self:check_eyedropper_position()
	end
end

function ColorPicker:set_value(value)
	self.value = value
end

function ColorPicker:set_saturation(saturation)
	self.saturation = saturation
end

function ColorPicker:check_eyedropper_position()
	local gamut_box = self._panel:child("gamut_box_bg")
	
	local x,y = gamut_box:position()
	local w,h = gamut_box:size()
	
	self._panel:child("eyedropper_circle"):set_center(x + (w * self.saturation),y + (h * (1 - self.value)))
end

function ColorPicker:get_previous_color()
	return self.previous_color
end

function ColorPicker:set_previous_color(color)
	self.previous_color = color
	self._panel:child("preview_previous_box"):set_color(color)
end

function ColorPicker:copy_current_color() --copies the hex value of the current color to the clipboard
	Application:set_clipboard(self:get_current_color():to_hex())
end

function ColorPicker:paste_to_current_color()
	local color = self:get_clipboard_color()
	if color then 
		self:set_current_color(color)
	end
end

function ColorPicker:get_clipboard_color()
	local s = Application:get_clipboard()
	if s then 
		return self:parse_color(tostring(s))
	end
end

function ColorPicker:parse_color(_input)
	--does its darndest to interpret a color from input of multiple types,
	--but without taking the lame way out and returning a black color if no color interpretation was found
	local input = string.gsub(_input,"%s","")

	if Color[input] and type(Color[input]) == "userdata" then 
		return Color[input]
	elseif input == "magenta" then --red, yellow, green, cyan, blue, purple, white, and black are all defined, among others. magenta and orange are not
		return Color(1,0,1)
	elseif input == "orange" then 
		return Color(1,0.5,0)
	end
	
	local a,b = string.find(input,"0x")
	if b and string.len(input) > b then   --find hex string
		a = string.sub(input,b+1)
		if a then 
			return Color:from_hex(a)
		end
	end
	local a,b = string.find(input,"#")
	if b and string.len(input) > b then   --find hex string, but again (hashtag signifier instead of 0x)
		a = string.sub(input,b+1)
		if a then 
			return Color:from_hex(a)
		end
	end
	
	
	if string.len(input) == 6 then 
		local potential_hex = string.lower(input)
		if not string.find(potential_hex,"[ghijklmnopqrstuvwxyz]") then 
			if string.gsub(potential_hex,"%w","") == "" then 
				return Color:from_hex(potential_hex)
			end
		end
	end
	
	b = getmetatable(input) 
	if type(b) == "table" then 
		if b.type_name == "Vector3" then 
			return Color(unpack(input))
		end
	end
	
	a = LuaNetworking:StringToColour(input)
	if a then 
		return a
	end
	
	if type(_input) == "table" then 
		if _input[1] and _input[2] and _input[3] and (type(_input[1]) == "number" and type(_input[2]) == "number" and type(_input[3]) == "number") then 
			if _input[1] > 1 or _input[2] > 1 or _input[3] > 1 then 
				return Color(_input[1]/255,_input[2]/255,_input[3]/255)
			else
				return Color(_input[1],_input[2],_input[3])
			end
		end
		return Color(unpack(_input))
	end
	
	if type(_input) == "number" then --get hex string from number
		return Color(string.format("%X",_input))
	else
		-- attempt converting input to a number, then that number to hex
		b = tonumber(input)
		if b then 
			return Color(string.format("%X",b))
		end
	end
	
	
--	return Color(input) 
end

function ColorPicker:pre_destroy()
	if ColorPicker.current_menu == self then 
		ColorPicker.current_menu = nil
	end
	if alive(self._panel) then 
		self._panel:parent():remove(self._panel)
	end
	self._panel = nil
end

function ColorPicker:get_palettes()
	local result = {}
	for i = 1,self.num_palettes,1 do 
		local palette_name = "palette_" .. i
		local palette = self._panel:child(palette_name)
		if alive(palette) then 
			table.insert(result,i,palette:color())
		end
	end
	return result
end

function ColorPicker:reset_palettes()
	self.parameters.palette = table.deep_map_copy(self.parameters.default_palettes)
	for i = 1,self.num_palettes,1 do 
		local palette_name = "palette_" .. i
		local palette = self._panel:child(palette_name)
		if alive(palette) then 
			palette:set_color(self.parameters.palette[i] or Color.white)
		end
	end
end

function ColorPicker:get_mouseover_object(x,y)
	local panel = self._panel
	if not (panel and alive(panel) and x and y) then
		return
	end
	for name,data in pairs(self._mouseover_objects) do 
		local obj = panel:child(name)
		if alive(obj) then 
			if obj:inside(x,y) then 
				return name,obj
			end
		end
	end
end

function ColorPicker:on_mouse_moved(o,x,y)
	local panel = self._panel
	
	local prev_moused_object_name = self._moused_object_name

	if ColorPicker.mouse0_held then 
		local moused_object_data = self._mouseover_objects[prev_moused_object_name]
		if moused_object_data and moused_object_data.callbacks.leftdrag then 
			moused_object_data.callbacks.leftdrag(x,y)
		end
	end
	
	local moused_object_name = self:get_mouseover_object(x,y)
	if not held_color then
		if prev_moused_object_name ~= moused_object_name then --if mouseover changed then 
			if prev_moused_object_name and self._mouseover_objects[prev_moused_object_name] then 
				--if previous moused object exists, then do mouseover end event if extant
				if self._mouseover_objects[prev_moused_object_name].callbacks.mouseover_end then 
					self._mouseover_objects[prev_moused_object_name].callbacks.mouseover_end(x,y,self._panel:child(prev_moused_object_name))
				end
				if not ColorPicker.mouse0_held then 
					self:set_tooltip(managers.localization:text("menu_colorpicker_prompt_default"))
				end
			end
			if moused_object_name and not ColorPicker.mouse0_held then
				self._moused_object_name = moused_object_name --save this object so that we don't have to perform multiple mouseover checks at once
				
				--if new mouseover exists then do mouseover event
				local moused_object_data = self._mouseover_objects[moused_object_name]
				if moused_object_data then 
					if moused_object_data.callbacks.mouseover then 
						moused_object_data.callbacks.mouseover(x,y,self._panel:child(moused_object_name))
					else
						self:set_pointer_image("arrow")
					end
					
					if moused_object_data.mouseover_tooltip then 
						self:set_tooltip(moused_object_data.mouseover_tooltip)
					end
				end
			end
		end
	elseif moused_object_name then 
		if self._mouseover_objects[moused_object_name] and self._mouseover_objects[moused_object_name].callbacks.drop_color then 
			--todo ui indication that object can be dropped?
		end
	end

	
	if not ColorPicker.mouse0_held then
		if moused_object_name then 
			moused_object_data = self._mouseover_objects[moused_object_name]
			if not moused_object_data.callbacks.mouseover then 
			end
		else
			self._moused_object_name = nil
			self:set_pointer_image("arrow")
		end
	end
		
	--todo make this work more gooder; reset color in released
	--[[
	local held_color = self:get_held_color()
	local pointer = o:child("pointer")
	if pointer then 
		if held_color then 
			pointer:set_color(held_color)
		end
	else
		pointer:set_color(Color.white)
	end
	--]]
	
end

function ColorPicker:on_mouse_pressed(o,button,x,y)
	local moused_object_name = self._moused_object_name or self:get_mouseover_object(x,y)
	local moused_object_data
	if moused_object_name then 
		moused_object_data = self._mouseover_objects[moused_object_name]
	end
	if button == leftclick then 
		if not ColorPicker.mouse0_held and moused_object_data then 
			if moused_object_data.callbacks.on_leftdrag then 
				moused_object_data.callbacks.on_leftdrag()
			end
		end
		ColorPicker.mouse0_held = true
	elseif button == rightclick then 
		ColorPicker.mouse1_held = true
	end
	
end

function ColorPicker:on_mouse_clicked(o,button,x,y)
	local moused_object_name = self:get_mouseover_object(x,y)
	local moused_object_data
	if moused_object_name then 
		moused_object_data = self._mouseover_objects[moused_object_name]
	end
	if button == leftclick then 
		if moused_object_data and moused_object_data.callbacks.leftclick then 
			moused_object_data.callbacks.leftclick(x,y)
		end
	elseif button == rightclick then 
		if moused_object_data and moused_object_data.callbacks.rightclick then 
			moused_object_data.callbacks.rightclick(x,y)
		end
	end
	self.held_color = nil
end

function ColorPicker:on_mouse_released(o,button,x,y)
	local moused_object_name = self._moused_object_name or self:get_mouseover_object(x,y)
	local moused_object_data
	if moused_object_name then 
		moused_object_data = self._mouseover_objects[moused_object_name]
	end
	if button == leftclick then 
		ColorPicker.mouse0_held = false
		local held_color = self:get_held_color()
		if held_color then 
			--check mouseover object if held color
			moused_object_name = self:get_mouseover_object(x,y)
			moused_object_data = moused_object_name and self._mouseover_objects[moused_object_name]
			if moused_object_data and moused_object_data.callbacks.drop_color then 
				moused_object_data.callbacks.drop_color(held_color)
			end
			self:set_held_color(nil)
		end
	elseif button == rightclick then
		ColorPicker.mouse1_held = false
	end
	self:set_pointer_image("arrow")
	self._moused_object_name = nil
end

function ColorPicker:on_mouse_doubleclicked(o,button,x,y)
	local moused_object_name = self:get_mouseover_object(x,y)
	local moused_object_data = moused_object_name and self._mouseover_objects[moused_object_name]
	if button == leftclick then 
		if moused_object_data and moused_object_data.callbacks.leftdoubleclick then 
			moused_object_data.callbacks.leftdoubleclick()
		end
	elseif button == rightclick then 
		if moused_object_data and moused_object_data.callbacks.rightdoubleclick then 
			moused_object_data.callbacks.rightdoubleclick()
		end	
	end
end

function ColorPicker:key_press(o,k) --nonfunctional for reasons unknown
	if k == Idstring("c") or k == Idstring("esc") or k == Idstring("escape") then
		self:Hide(false,true)
	elseif k == Idstring("a") or k == Idstring("enter") then 
		self:Hide(true,true)
--	elseif k == Idstring("insert") or (k == Idstring("v") and ctrl_held) then --todo paste from clipboard through keystroke
	end
end

function ColorPicker.color_to_hex(color)
	if not color then return end
	if Color.to_hex then 
		return Color.to_hex(color)
	end
	return string.format("%x%x%x", color.r * 255,color.g * 255,color.b * 255)
end

local mod_path = ModPath
Hooks:Add("BaseNetworkSessionOnLoadComplete","colorpicker_onloaded",ColorPicker.CreateQueuedMenus)
Hooks:Add("LocalizationManagerPostInit", "colorpicker_addlocalization", function( loc )
	if not BeardLib then 
		--shouldn't ever be necessary since BeardLib is required for this mod
		loc:load_localization_file( mod_path .. "localization/english.json" )
	end
end)
