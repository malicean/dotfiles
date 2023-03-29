local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local IDSKEY_BACKSPACE = Idstring('backspace'):key()
local IDSKEY_DELETE = Idstring('delete'):key()
local IDSKEY_DOWN = Idstring('down'):key()
local IDSKEY_END = Idstring('end'):key()
local IDSKEY_ENTER = Idstring('enter'):key()
local IDSKEY_ESC = Idstring('esc'):key()
local IDSKEY_HOME = Idstring('home'):key()
local IDSKEY_LEFT = Idstring('left'):key()
local IDSKEY_LEFTALT = Idstring('left alt'):key()
local IDSKEY_LEFTCONTROL = Idstring('left ctrl'):key()
local IDSKEY_LEFTSHIFT = Idstring('left shift'):key()
local IDSKEY_NUMENTER = Idstring('num enter'):key()
local IDSKEY_PAGEDOWN = Idstring('page down'):key()
local IDSKEY_PAGEUP = Idstring('page up'):key()
local IDSKEY_RIGHT = Idstring('right'):key()
local IDSKEY_RIGHTALT = Idstring('right alt'):key()
local IDSKEY_RIGHTCONTROL = Idstring('right ctrl'):key()
local IDSKEY_RIGHTSHIFT = Idstring('right shift'):key()
local IDSKEY_TAB = Idstring('tab'):key()
local IDSKEY_UP = Idstring('up'):key()

_G.QuickKeyboardInput = QuickKeyboardInput or blt_class(QuickMenu)

function QuickKeyboardInput:init(title, text, p1, p2, p3, p4)
	QuickKeyboardInput.super.init(self, title, text, {}, false)

	local show_immediately
	-- legacy:
		-- p1: default_value,
		-- p2: changed_callback,
		-- p3: max_length,
		-- p4: show_immediately
	local v1 = type(p2) == 'function'
		and (type(p3) == 'number' or type(p3) == 'nil')
		and (type(p4) == 'boolean' or type(p4) == 'nil')
	-- v2:
		-- p1: params,
		-- p2: show_immediately
	local v2 = type(p1) == 'table'
		and (type(p2) == 'boolean' or type(p2) == 'nil')

	if v2 then
		for k, v in pairs(p1) do
			self.dialog_data[k] = v
		end
		show_immediately = p2
	elseif v1 then
		self.dialog_data.default_value = p1
		self.dialog_data.changed_callback = p2
		self.dialog_data.max_length = p3
		show_immediately = p4
	else
		return
	end

	if show_immediately then
		self:show()
	end

	return self
end

function QuickKeyboardInput:Show()
	if not self.visible then
		self.visible = true
		managers.system_menu:show_keyboard_input(self.dialog_data)
	end
end

_G.QuickKeyboardInputGui = QuickKeyboardInputGui or class(TextBoxGui)

QuickKeyboardInputGui.qki_caret_width = 2
QuickKeyboardInputGui.qki_breakers = {
	['('] = '(',
	[')'] = ')',
	['['] = '[',
	[']'] = ']',
	['{'] = '{',
	['}'] = '}',
	['|'] = '|',
	['_'] = '_',
	['\\'] = '\\',
	['/'] = '/',
	['*'] = '*',
	['+'] = '+',
	['-'] = '-',
	['='] = '=',
	['#'] = '#',
	['@'] = '@',
	['&'] = '&',
	['!'] = '!',
	['?'] = '?',
	[':'] = ':',
	[';'] = ';',
	[','] = ',',
	['.'] = '.',
	[' '] = ' ',
	['	'] = '	',
	['\n'] = '\n',
}

function QuickKeyboardInputGui:init(...)
	self:qki_init()
	QuickKeyboardInputGui.super.init(self, ...)
end

function QuickKeyboardInputGui:qki_init()
	self.qki_text = ''
	self.qki_text_len = 0
	self.qki_curpos = 0
	self.qki_key_down = {}
	self.qki_mouse_down = {}
end

function QuickKeyboardInputGui:_setup_buttons_panel(...)
	local panel = QuickKeyboardInputGui.super._setup_buttons_panel(self, ...)
	panel:set_h(0)
	return panel
end

function QuickKeyboardInputGui:qki_set_listening_to_input(state)
	self.qki_listening_to_input = state

	if managers.menu then
		local menu = managers.menu:active_menu()
		if menu then
			if self.qki_is_husk then
				menu.input:set_back_enabled(not state)
				menu.input:accept_input(not state)
				menu.input:set_force_input(not state)
				if menu.renderer then
					menu.renderer:disable_input(0.2) -- block confirm_pressed() & co
				end
				if self.qki_content_data.no_mouse then
					if state then
						managers.menu:active_menu().input:deactivate_mouse()
					else
						managers.menu:active_menu().input:activate_mouse()
					end
				end
			end

			local node_gui = menu.renderer and menu.renderer:active_node_gui()
			if node_gui then
				if state and not node_gui._listening_to_input then
					node_gui._listening_to_input = 1
				elseif type(node_gui._listening_to_input) == 'number' then
					local dv = state and 1 or -1
					local new_v = node_gui._listening_to_input + dv
					if new_v == 0 then
						node_gui._listening_to_input = nil
					else
						node_gui._listening_to_input = new_v -- for chained QKI
					end
				end
			end
		end
	end

	if state then
		if BLT.Keybinds.enter_edit then
			BLT.Keybinds:enter_edit('QuickKeyboardInput' .. tostring(self))
		end
		if self.qki_ws then
			self.qki_ws:connect_keyboard(Input:keyboard())
			if not self.qki_content_data.no_mouse then
				self.qki_ws:connect_mouse(Input:mouse())
				self.qki_ws:feed_mouse_position(managers.mouse_pointer:mouse():world_position())
			end
		end
		self.qki_inputtext:enter_text(callback(self, self, 'qki_enter_text'))
		self.qki_inputtext:key_press(callback(self, self, 'qki_key_press'))
		self.qki_inputtext:key_release(callback(self, self, 'qki_key_release'))
		if not self.qki_content_data.no_mouse then
			if self.qki_is_husk then
				self.qki_mouse_id = managers.mouse_pointer:get_id()
				managers.mouse_pointer:use_mouse({
					id = self.qki_mouse_id,
					mouse_move = callback(self, self, 'qki_mouse_move'),
					mouse_press = callback(self, self, 'qki_mouse_press'),
					mouse_release = callback(self, self, 'qki_mouse_release'),
				})
				managers.mouse_pointer:enable()
			else
				call_on_next_update(function()
					self.qki_inputtext:mouse_move(callback(self, self, 'qki_mouse_move'))
					self.qki_inputtext:mouse_press(callback(self, self, 'qki_mouse_press'))
					self.qki_inputtext:mouse_release(callback(self, self, 'qki_mouse_release'))
				end)
			end
		end

	else
		if BLT.Keybinds.exit_edit then
			BLT.Keybinds:exit_edit('QuickKeyboardInput' .. tostring(self))
		end
		if self.qki_ws then
			self.qki_ws:disconnect_keyboard(Input:keyboard())
			if not self.qki_content_data.no_mouse then
				self.qki_ws:disconnect_mouse(Input:mouse())
			end
		end
		self.qki_inputtext:enter_text(nil)
		self.qki_inputtext:key_press(nil)
		self.qki_inputtext:key_release(nil)
		if not self.qki_content_data.no_mouse then
			if self.qki_is_husk then
				if self.qki_mouse_id then
					managers.mouse_pointer:remove_mouse(self.qki_mouse_id)
					self.qki_mouse_id = nil
				end
			else
				self.qki_inputtext:mouse_move(nil)
				self.qki_inputtext:mouse_press(nil)
				self.qki_inputtext:mouse_release(nil)
			end
		end
	end
end

function QuickKeyboardInputGui.blink(o)
	while true do
		o:set_color(Color(0, 1, 1, 1))
		wait(0.25)
		o:set_color(Color(0.5, 1, 1, 1))
		wait(0.25)
	end
end

function QuickKeyboardInputGui:qki_setup_edit_caret()
	self.qki_edit_caret = self.qki_inputtext:parent():rect({
		name = 'caret',
		h = self.qki_inputtext:line_height(),
		y = 0,
		w = self.qki_caret_width,
		x = 0,
		layer = self.qki_inputtext:layer() + 1,
		color = Color(0.5, 1, 1, 1)
	})

	self.qki_edit_caret:animate(self.blink)
end

function QuickKeyboardInputGui:qki_set_text(txt, no_trick, no_gui_update)
	if self.qki_not_editable then
		return
	end

	self.qki_text = txt
	self.qki_text_len = utf8.len(txt)
	
	if no_gui_update then
		return
	end

	if txt:sub(-1, -1) ~= '\n' or no_trick then
		self.qki_inputtext:set_text(txt)
	else
		self.qki_inputtext:set_text(txt .. ' ')
	end
end

function QuickKeyboardInputGui:_create_text_box(ws, title, text, content_data, config)
	self.qki_ws = ws
	self.qki_content_data = content_data

	if content_data.w then
		config.type = nil
		config.w = content_data.w
	end

	config.font = content_data.font
	config.font_size = content_data.font_size
	config.forced_h = content_data.forced_h
	config.is_title_outside = content_data.is_title_outside
	config.text_blend_mode = content_data.text_blend_mode
	config.text_formating_color = content_data.text_formating_color
	config.text_formating_color_table = content_data.text_formating_color_table
	config.title_font = content_data.title_font
	config.title_font_size = content_data.title_font_size
	config.use_text_formating = content_data.use_text_formating

	local main = QuickKeyboardInputGui.super._create_text_box(self, ws, title, text, content_data, config)

	local config_type = config and config.type
	local preset = config_type and self.PRESETS[config_type]
	local text_blend_mode = preset and preset.text_blend_mode or config and config.text_blend_mode or 'normal'
	local font = preset and preset.font or config and config.font or tweak_data.menu.pd2_medium_font
	local font_size = preset and preset.font_size or config and config.font_size or tweak_data.menu.pd2_medium_font_size

	if self.qki_content_data.no_corners then
		self._info_box:close()
	end

	local message = self._scroll_panel:child('text')
	local inputtext = self._scroll_panel:text({
		name = 'inputtext',
		wrap = content_data.word_wrap,
		align = content_data.halign or 'left',
		vertical = content_data.valign or 'top',
		layer = message:layer() + 1,
		text = '',
		visible = true,
		w = self._scroll_panel:w() - 2 * message:x(),
		h = 0,
		x = message:x(),
		y = message:bottom() + message:line_height() / 2,
		font = font,
		font_size = content_data.input_font_size or font_size,
		blend_mode = text_blend_mode
	})
	self.qki_inputtext = inputtext

	local input_value = tostring(content_data.default_value or '')
	self:qki_set_text(self:qki_clamp(input_value))
	self.qki_not_editable = content_data.not_editable

	self.qki_curpos = self.qki_text_len
	if content_data.set_selection_from then
		self.qki_curpos = math.min(self.qki_curpos, content_data.set_selection_from)
	end
	if content_data.set_selection_to then
		self:qki_select(content_data.set_selection_to)
	end

	self:qki_setup_edit_caret()
	self:qki_update_dialog_height()
	self:qki_update_caret_position()
	self:qki_follow_edit_caret()

	self:qki_set_listening_to_input(true)

	return main
end

function QuickKeyboardInputGui:qki_select(b)
	local a = self.qki_sel_base or self.qki_curpos

	if a > b then
		a, b = b, a
	end

	self.qki_inputtext:set_selection(a, b)
end

function QuickKeyboardInputGui:qki_update_selection()
	if not self:qki_is_shift_down() then
		self.qki_sel_base = self.qki_curpos
	end
	self:qki_select(self.qki_curpos)
end

function QuickKeyboardInputGui:qki_get_number_of_lines()
	return math.max(1, self.qki_inputtext:number_of_lines())
end

function QuickKeyboardInputGui:qki_update_dialog_height()
	if not self.qki_inputtext then
		return
	end

	local nl = math.max(1, self:qki_get_number_of_lines())
	local lh = self.qki_inputtext:line_height()
	local h = lh * nl
	if math.abs(h - self.qki_inputtext:h()) < 0.001 then
		return
	end

	local forced_h = self.qki_content_data.forced_h
	local message = self._scroll_panel:child('text')
	self.qki_initial_message_bottom = self.qki_initial_message_bottom or message:bottom() + message:line_height() / 2
	local new_h = math.max(forced_h or 0, self.qki_initial_message_bottom + h)
	local shrink = new_h < message:h()
	message:set_h(new_h)

	self.qki_inputtext:set_h(math.max(forced_h and forced_h - self.qki_initial_message_bottom or 0, h))
	if self.qki_content_data.valign == 'bottom' then
		self.qki_inputtext:set_bottom(message:bottom())
	else
		self.qki_inputtext:set_top(message:top() + self.qki_initial_message_bottom)
	end

	if forced_h then
		-- qued
	elseif self.qki_content_data.max_lines and nl >= self.qki_content_data.max_lines then
		-- qued
	elseif shrink and message:h() < self.qki_ws:height() or self._panel:top() > lh * 1.5 then
		local hc = message:world_bottom() - self._text_box:world_top() + 10
		local diff = math.min(0, self.qki_ws:height() - lh * 1.5 - hc)
		self._text_box:set_h(hc + diff)
		local info_area = self._text_box:child('info_area')
		info_area:set_h(hc + diff)

		local hcc = message:world_bottom() - self._scroll_panel:world_top() + 10
		self._scroll_panel:set_h(hcc + diff)

		if self._info_box then
			self._info_box:close()
			if not self.qki_content_data.no_corners then
				self._info_box = BoxGuiObject:new(info_area, {sides = { 1, 1, 1, 1 }})
			end
		end
		self:set_centered()
	end

	self:_set_scroll_indicator()
end

function QuickKeyboardInputGui:scroll_up(y)
	y = y * (self.qki_content_data.scroll_by_x_lines or 3)

	QuickKeyboardInputGui.super.scroll_up(self, y)

	if alive(self.qki_inputtext) then
		self.qki_inputtext:set_bottom(self._scroll_panel:child('text'):bottom())
		self:_check_scroll_indicator_states()
		self:qki_update_caret_position()
	end
end

function QuickKeyboardInputGui:scroll_down(y)
	y = y * (self.qki_content_data.scroll_by_x_lines or 3)

	QuickKeyboardInputGui.super.scroll_down(self, y)

	if alive(self.qki_inputtext) then
		self.qki_inputtext:set_bottom(self._scroll_panel:child('text'):bottom())
		self:_check_scroll_indicator_states()
		self:qki_update_caret_position()
	end
end

function QuickKeyboardInputGui:qki_follow_edit_caret()
	local y = self.qki_edit_caret:world_y()
	if y >= self._scroll_panel:world_bottom() then
		self:scroll_down(y - self._scroll_panel:world_bottom() + self.qki_inputtext:line_height())
	elseif y < self._scroll_panel:world_top() then
		self:scroll_up(self._scroll_panel:world_top() - y)
	end
end

function QuickKeyboardInputGui:qki_get_startx()
	local startx = self.qki_inputtext:world_x()
	local halign = self.qki_inputtext:align()
	if halign == 'left' then
		-- qued
	elseif halign == 'center' then
		startx = startx + self.qki_inputtext:w() / 2
	elseif halign == 'right' then
		startx = startx + self.qki_inputtext:w()
	end
	return startx
end

function QuickKeyboardInputGui:qki_get_starty()
	local starty = self.qki_inputtext:world_y()
	local valign = self.qki_inputtext:vertical()
	if valign == 'top' then
		-- qued
	elseif valign == 'center' then
		starty = starty + (self.qki_inputtext:h() - self:qki_get_number_of_lines() * self.qki_inputtext:line_height()) / 2
	elseif valign == 'bottom' then
		starty = starty + self.qki_inputtext:h() - self:qki_get_number_of_lines() * self.qki_inputtext:line_height()
	end
	return starty
end

function QuickKeyboardInputGui:qki_update_caret_position()
	if not self.qki_edit_caret or not self.qki_inputtext then
		return
	end

	local function char_at(i)
		return utf8.sub(self.qki_text, i, i)
	end

	local cx, cy, cw
	if self.qki_curpos == 0 then
		cw = 0
		if self.qki_text_len == 0 or char_at(1) == '\n' then
			cx = self:qki_get_startx()
			cy = self:qki_get_starty()
		else
			cx, cy = self.qki_inputtext:character_rect(0)
		end
	else
		cx, cy, cw = self.qki_inputtext:character_rect(self.qki_curpos - 1)
		local c = char_at(self.qki_curpos)
		if c == '\n' then
			cw = 0
			if self.qki_curpos == self.qki_text_len or char_at(self.qki_curpos + 1) == '\n' then
				cx = self:qki_get_startx()
			end
		elseif c == ' ' and cw == 1 then
			for i = self.qki_curpos, 1, -1 do
				if char_at(i) ~= ' ' then
					cx = self.qki_inputtext:character_rect(i - 1) + math.floor((2 + self.qki_curpos - i) * (33/200) * self.qki_inputtext:font_size())
					break
				end
			end
		end
	end

	local x = cx + cw
	if halign == 'right' then
		x = x - self.qki_caret_width
	end

	self.qki_edit_caret:set_world_position(x, cy)
end

function QuickKeyboardInputGui:qki_line_start(txt, curpos)
	local i = curpos
	for i = curpos, 1, -1 do
		if utf8.sub(txt, i, i) == '\n' then
			return i
		end
	end
	return 0
end

function QuickKeyboardInputGui:qki_line_end(txt, curpos)
	local n = self.qki_text_len
	for i = curpos, n - 1 do
		local c = utf8.sub(txt, i + 1, i + 1)
		if c == '\n' then
			return i
		end
	end
	return n
end

function QuickKeyboardInputGui:qki_previous_word_start(txt, curpos)
	local i = curpos
	while i > 0 do
		local ci = utf8.sub(txt, i, i)
		if not self.qki_breakers[ci] then
			break
		end
		i = i - 1
	end

	while i > 0 do
		local ci = utf8.sub(txt, i, i)
		if self.qki_breakers[ci] then
			return i
		end
		i = i - 1
	end
end

function QuickKeyboardInputGui:qki_next_word_end(txt, curpos)
	local n = self.qki_text_len
	local i = curpos + 1
	while i <= n do
		local ci = utf8.sub(txt, i, i)
		if self.qki_breakers[ci] then
			break
		end
		i = i + 1
	end

	while i <= n do
		local ci = utf8.sub(txt, i, i)
		if not self.qki_breakers[ci] then
			return i - 1
		end
		i = i + 1
	end
end

function QuickKeyboardInputGui:qki_delete_selection()
	local s, e = self.qki_inputtext:selection()
	if s == e then
		return false
	end

	self.qki_curpos = s
	self.qki_inputtext:set_selection(s, s)

	return utf8.sub(self.qki_text, 1, s) .. utf8.sub(self.qki_text, e + 1), utf8.sub(self.qki_text, s + 1, e)
end

function QuickKeyboardInputGui:qki_clamp(txt)
	if type(self.qki_content_data.max_length) == 'number' and utf8.len(txt) > self.qki_content_data.max_length then
		txt = utf8.sub(txt, 1, self.qki_content_data.max_length)
	end
	if type(self.qki_content_data.max_size) == 'number' and string.len(txt) > self.qki_content_data.max_size then
		txt = txt:sub(1, self.qki_content_data.max_size)
	end
	return txt
end

function QuickKeyboardInputGui:qki_is_ctrl_down()
	return self.qki_key_down[IDSKEY_LEFTCONTROL] or self.qki_key_down[IDSKEY_RIGHTCONTROL] 
end

function QuickKeyboardInputGui:qki_is_shift_down()
	return self.qki_key_down[IDSKEY_LEFTSHIFT] or self.qki_key_down[IDSKEY_RIGHTSHIFT] 
end

function QuickKeyboardInputGui:qki_text_is_changing(txt)
	local clbk = self.qki_content_data.changing_callback
	if type(clbk) == 'function' then
		if txt ~= self.qki_text then
			clbk(txt)
		end
	end
end

function QuickKeyboardInputGui:qki_previous_line_bounds(txt, curpos)
	local e = self:qki_line_start(txt, curpos)
	local s = self:qki_line_start(txt, e - 1)
	return s, e - 1
end

function QuickKeyboardInputGui:qki_next_line_bounds(txt, curpos)
	local s = self:qki_line_end(txt, curpos) + 1
	local e = self:qki_line_end(txt, s) + 1
	return s, e - 1
end

function QuickKeyboardInputGui:qki_closest_char(x, from, to)
	for i = from, to do
		local cx, _, cw = self.qki_inputtext:character_rect(i - 1)
		if x >= cx and x <= cx + cw then
			if i > from and x < cx + cw/2 then
				i = i - 1
			end
			return i
		end
	end
	return to
end

function QuickKeyboardInputGui:qki_enter_text(o, s, no_ctrl_check)
	if not self.qki_last_pressed_key then
		return
	end

	local txt = self.qki_text

	local i = string.len(s) == 1 and string.byte(s)
	if i == 1 then -- ctrl a
		self.qki_sel_base = 0
		self.qki_curpos = self.qki_text_len
		self:qki_select(self.qki_text_len)
		self:qki_update_caret_position()
		return

	elseif i == 3 then -- ctrl c
		local s1, s2 = self.qki_inputtext:selection()
		Application:set_clipboard(s1 == s2 and txt or utf8.sub(txt, s1 + 1, s2))
		return

	elseif i == 22 then -- ctrl v
		local cp = Application:get_clipboard()
		if type(cp) == 'string' then
			self:qki_enter_text(o, cp, true)
			self:qki_update_selection()
		end
		return

	elseif i == 24 then -- ctrl x
		local txtcut, ct = self:qki_delete_selection()
		if txtcut then
			Application:set_clipboard(ct)
			txt = txtcut
			self:qki_update_selection()
		end

	elseif not no_ctrl_check and self:qki_is_ctrl_down() then
		return

	else
		txt = self:qki_delete_selection() or txt
		txt = utf8.sub(txt, 1, self.qki_curpos) .. tostring(s) .. utf8.sub(txt, self.qki_curpos + 1)
		self.qki_curpos = self.qki_curpos + utf8.len(s)
	end

	txt = self:qki_clamp(txt)
	self:qki_text_is_changing(txt)
	self:qki_set_text(txt)

	self:qki_update_dialog_height()
	self:qki_update_caret_position()
	self:qki_follow_edit_caret()
end

function QuickKeyboardInputGui:qki_key_release(o, k)
	local kkey = k:key()
	self.qki_key_down[kkey] = false

	if kkey == self.qki_last_pressed_key then
		self.qki_inputtext:stop()
	end
end

function QuickKeyboardInputGui:qki_key_press(o, k, repeated)
	local kkey = k:key()

	self.qki_previous_vertical_move_on_x = self.qki_vertical_move_on_x
	self.qki_vertical_move_on_x = nil

	if repeated == true then
		if not self.qki_key_down[kkey] then
			return
		end
	elseif repeated == false then
		-- qued
	else
		self.qki_key_down[kkey] = true
		self.qki_last_pressed_key = kkey
		self.qki_inputtext:stop()

		if kkey == IDSKEY_ENTER or kkey == IDSKEY_ESC then
			-- qued
		elseif kkey == IDSKEY_LEFTALT or kkey == IDSKEY_RIGHTALT then
			-- qued
		else
			local function not_a_fugly_repeat()
				wait(0.5)
				while true do
					self:qki_key_press(o, k, true)
					wait(0.05)
				end
			end
			self.qki_inputtext:animate(not_a_fugly_repeat)
		end
	end

	local initial_number_of_lines = self:qki_get_number_of_lines()
	local initial_curpos = self.qki_curpos
	local txt = self.qki_text
	local text_modified

	if kkey == IDSKEY_LEFT then
		if self:qki_is_ctrl_down() then
			local pws = self:qki_previous_word_start(txt, self.qki_curpos)
			self.qki_curpos = pws or 0
		else
			self.qki_curpos = math.max(0, self.qki_curpos - 1)
		end

	elseif kkey == IDSKEY_RIGHT then
		if self:qki_is_ctrl_down() then
			local nwe = self:qki_next_word_end(txt, self.qki_curpos)
			self.qki_curpos = nwe or self.qki_text_len
		else
			self.qki_curpos = math.min(self.qki_text_len, self.qki_curpos + 1)
		end

	elseif kkey == IDSKEY_UP then
		local s, e = self:qki_previous_line_bounds(txt, self.qki_curpos)
		if e <= 0 then
			self.qki_curpos = 0
		else
			self.qki_vertical_move_on_x = self.qki_previous_vertical_move_on_x or self.qki_edit_caret:world_center_x()
			self.qki_curpos = self:qki_closest_char(self.qki_vertical_move_on_x, s, e)
		end

	elseif kkey == IDSKEY_DOWN then
		local s, e = self:qki_next_line_bounds(txt, self.qki_curpos)
		if e == 0 then
			self.qki_curpos = 0
		else
			self.qki_vertical_move_on_x = self.qki_previous_vertical_move_on_x or self.qki_edit_caret:world_center_x()
			self.qki_curpos = self:qki_closest_char(self.qki_vertical_move_on_x, s, e)
		end

	elseif kkey == IDSKEY_PAGEUP then
		local x, y = self.qki_edit_caret:world_center()
		local dy = self._panel:h() - self.qki_inputtext:line_height()
		self.qki_curpos = self.qki_inputtext:point_to_index(x, y - dy)
		self:scroll_up(dy)

	elseif kkey == IDSKEY_PAGEDOWN then
		local x, y = self.qki_edit_caret:world_center()
		local dy = self._panel:h() - self.qki_inputtext:line_height()
		self.qki_curpos = self.qki_inputtext:point_to_index(x, y + dy)
		self:scroll_down(dy)

	elseif kkey == IDSKEY_HOME then
		if self:qki_is_ctrl_down() then
			self.qki_curpos = 0
		else
			self.qki_curpos = self:qki_line_start(txt, self.qki_curpos)
		end

	elseif kkey == IDSKEY_END then
		if self:qki_is_ctrl_down() then
			self.qki_curpos = self.qki_text_len
		else
			self.qki_curpos = self:qki_line_end(txt, self.qki_curpos)
		end

	elseif kkey == IDSKEY_DELETE then
		local txt_no_sel = self:qki_delete_selection()
		if txt_no_sel then
			text_modified = true
			txt = txt_no_sel
		elseif self.qki_curpos < self.qki_text_len then
			text_modified = true
			if self:qki_is_ctrl_down() then
				local nwe = self:qki_next_word_end(txt, self.qki_curpos)
				txt = utf8.sub(txt, 1, self.qki_curpos) .. (nwe and utf8.sub(txt, nwe + 1) or '')
			else
				txt = utf8.sub(txt, 1, self.qki_curpos) .. utf8.sub(txt, self.qki_curpos + 2)
			end
		end

	elseif kkey == IDSKEY_BACKSPACE then
		local txt_no_sel = self:qki_delete_selection()
		if txt_no_sel then
			text_modified = true
			txt = txt_no_sel
		elseif self.qki_curpos > 0 then
			text_modified = true
			if self:qki_is_ctrl_down() then
				local pws = self:qki_previous_word_start(txt, self.qki_curpos)
				txt = (pws and utf8.sub(txt, 1, pws) or '') .. utf8.sub(txt, self.qki_curpos + 1)
				self.qki_curpos = pws or 0
			else
				txt = utf8.sub(txt, 1, self.qki_curpos - 1) .. utf8.sub(txt, self.qki_curpos + 1)
				self.qki_curpos = self.qki_curpos - 1
			end
		end

	elseif kkey == IDSKEY_TAB then
		self:qki_enter_text(o, '\t')
		return

	elseif kkey == IDSKEY_NUMENTER then
		if self.qki_content_data.multiline then
			self:qki_enter_text(o, '\n')
			return
		end

	elseif kkey == IDSKEY_ENTER then
		local clbk = self.qki_content_data.changed_callback
		if type(clbk) == 'function' then
			self:_close()
			self:qki_set_text(self.qki_text, true)
			clbk(self.qki_text)
			if self.qki_is_husk then
				self:close()
			end
		end
		return

	elseif kkey == IDSKEY_ESC then
		local clbk = self.qki_content_data.cancel_callback
		if type(clbk) == 'function' then
			self:_close()
			clbk()
			if self.qki_is_husk then
				self:close()
			end
		end
		return
	end

	if text_modified then
		self:qki_text_is_changing(txt)
		self:qki_set_text(txt)
		self:qki_update_dialog_height()

		local diff_lines = initial_number_of_lines - self:qki_get_number_of_lines()
		if diff_lines > 0 then
			self:scroll_up(diff_lines * self.qki_inputtext:line_height())
		end
	elseif initial_curpos ~= self.qki_curpos then
		self:qki_update_selection()
	end

	self:qki_update_caret_position()
	self:qki_follow_edit_caret()
end

function QuickKeyboardInputGui:qki_mouse_press(o, button, x, y)
	local bkey = button:key()
	self.qki_mouse_down[bkey] = true
	self.qki_last_pressed_mb = bkey

	if self.qki_is_husk then
		x, y = managers.mouse_pointer:convert_mouse_pos(x, y)
	end

	if button == Idstring('0') and self.qki_inputtext:inside(x, y) then
		self.qki_curpos = self.qki_inputtext:point_to_index(x, y)
		self:qki_update_caret_position()

		if not self:qki_is_shift_down() then
			self.qki_sel_base = self.qki_curpos
		end

		self:qki_select(self.qki_curpos)
	end
end

function QuickKeyboardInputGui:qki_mouse_release(o, button, x, y)
	if not self.qki_last_pressed_mb then
		return
	end

	local bkey = button:key()
	self.qki_mouse_down[bkey] = false

	if button == Idstring('0') then
		if self.qki_is_husk then
			x, y = managers.mouse_pointer:convert_mouse_pos(x, y)
		end

		local parent = self.qki_inputtext:parent()
		x = math.clamp(x, parent:world_left(), parent:world_right())
		y = math.clamp(y, parent:world_top(), parent:world_bottom())

		self.qki_curpos = self.qki_inputtext:point_to_index(x, y)
		self:qki_update_caret_position()
		self:qki_select(self.qki_curpos)
	end
end

function QuickKeyboardInputGui:qki_mouse_move(o, x, y)
	if not self.qki_last_pressed_mb then
		return
	end

	if self.qki_mouse_down[Idstring('0'):key()] then
		if self.qki_is_husk then
			x, y = managers.mouse_pointer:convert_mouse_pos(x, y)
		end

		local parent = self.qki_inputtext:parent()
		x = math.clamp(x, parent:world_left(), parent:world_right())
		y = math.clamp(y, parent:world_top(), parent:world_bottom())

		self.qki_curpos = self.qki_inputtext:point_to_index(x, y)
		self:qki_update_caret_position()
		self:qki_select(self.qki_curpos)
	end
end

function QuickKeyboardInputGui:_close()
	self.qki_inputtext:stop()

	if self.qki_edit_caret then
		self.qki_edit_caret:parent():remove(self.qki_edit_caret)
		self.qki_edit_caret = nil
	end

	if self.qki_listening_to_input then
		self:qki_set_listening_to_input(false)
	end
end

function QuickKeyboardInputGui:close()
	self:_close()

	if self.qki_inputtext then
		self.qki_inputtext:parent():remove(self.qki_inputtext)
		self.qki_inputtext = nil
	end

	QuickKeyboardInputGui.super.close(self)
end

-- this is a class to use keyboard key handling only, it owns nothing except focus and edit caret
_G.QuickKeyboardInputHusk = QuickKeyboardInputHusk or blt_class(QuickKeyboardInputGui)

function QuickKeyboardInputHusk:init(ws, input_text, params)
	self.qki_is_husk = true

	self:qki_init()

	self.qki_ws = ws
	self.qki_inputtext = input_text
	self.qki_content_data = params

	self.qki_text = input_text:text()
	self.qki_text_len = utf8.len(self.qki_text)

	self.qki_curpos = self.qki_text_len
	self:qki_setup_edit_caret()
	self:qki_update_caret_position()
	
	self:qki_set_listening_to_input(true)
end

local do_nothing = function() end
QuickKeyboardInputHusk.qki_follow_edit_caret = do_nothing
QuickKeyboardInputHusk.qki_update_dialog_height = do_nothing
QuickKeyboardInputHusk.scroll_down = do_nothing
QuickKeyboardInputHusk.scroll_up = do_nothing

function QuickKeyboardInputHusk:close()
	self:_close()
end
