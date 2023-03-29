local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.EnhancedHitmarkers = _G.EnhancedHitmarkers or {}
EnhancedHitmarkers._path = ModPath
EnhancedHitmarkers._data_path = SavePath .. 'enhanced_hitmarkers_options.txt'
EnhancedHitmarkers._data = {}
EnhancedHitmarkers.assets_path = ModPath .. 'hitmarkers/'
EnhancedHitmarkers.assets_path_custom = SavePath .. 'Enhanced Hitmarkers/'
EnhancedHitmarkers.texture_list = {}
EnhancedHitmarkers.settings = {
	hit_texture = 'classic hit v2.texture',
	kill_texture = 'TdlQ.texture',
}
EnhancedHitmarkers.texture_base = 'guis/textures/pd2/'
EnhancedHitmarkers.kill_texture_db = EnhancedHitmarkers.texture_base .. EnhancedHitmarkers.settings.kill_texture
EnhancedHitmarkers.hit_texture_db = EnhancedHitmarkers.texture_base .. EnhancedHitmarkers.settings.hit_texture

function EnhancedHitmarkers:reset()
	self.settings.body = 'ff5500'
	self.settings.head = '57ff00'
	self.settings.crit = 'ff00ff'
	self.settings.hcrit = '0057ff'
	self.settings.shake = true
	self.settings.blend_mode = 1
	self.settings.initial_hit_size_ratio = 1
	self.settings.initial_kill_size_ratio = 1
	self.settings.grow_ratio = 10
end

function EnhancedHitmarkers:load_custom_textures()
	local function dbize(old_texture_db, new_texture)
		if DB:has(Idstring('texture'), old_texture_db) then
			TextureCache:unretrieve(Idstring(old_texture_db))
			DB:remove_entry(Idstring('texture'), old_texture_db)
		end
		local new_texture_db = self.texture_base .. new_texture
		DB:create_entry(
			Idstring('texture'),
			Idstring(new_texture_db),
			self.assets_path_custom .. new_texture
		)
		TextureCache:retrieve(Idstring(new_texture_db))
		return new_texture_db
	end

	self.kill_texture_db = dbize(self.kill_texture_db, self.settings.kill_texture)
	self.hit_texture_db = dbize(self.hit_texture_db, self.settings.hit_texture)

	if managers.hud and managers.hud._hud_hit_confirm then
		managers.hud._hud_hit_confirm:eh_setup()
	end
end

function EnhancedHitmarkers:create_folder(path)
	local tmp = ''
	for folder in path:gmatch('[^\\/]+') do
		tmp = tmp .. folder .. '/'
		SystemFS:make_dir(tmp)
	end
end

function EnhancedHitmarkers:initialize_texture_folder()
	if not SystemFS:exists(self.assets_path_custom) then
		log('[Enhanced Hitmarkers] Creating Enhanced Hitmarkers overrides folder...')
		self:create_folder(self.assets_path_custom)
	end

	if SystemFS:exists(self.assets_path_custom) then
		local overrides = file.GetFiles(self.assets_path_custom)
		local sources = file.GetFiles(self.assets_path)
		for _, filename in pairs(sources) do
			if not io.file_is_readable(self.assets_path_custom .. filename) then
				log('[Enhanced Hitmarkers] Copying ' .. filename)
				local r = SystemFS:copy_file(self.assets_path .. filename, self.assets_path_custom .. filename)
				log('[Enhanced Hitmarkers] --> ' .. (r and 'success' or 'failure'))
			end
		end
	end
end

function EnhancedHitmarkers:multi_set_choice(multi, choice)
	for _, option in ipairs(multi._all_options) do
		if option:parameters().text_id == choice then
			multi:set_value(option:parameters().value)
			return
		end
	end
end

function EnhancedHitmarkers:is_texture(file)
	local result = false
	local fh = io.open(file, 'r')
	if fh then
		local header = fh:read(4)
		result = header:sub(1, 3) == 'DDS' or header:sub(2, 4) == 'PNG'
		fh:close()
	end
	return result
end

function EnhancedHitmarkers:list_available_textures()
	if #self.texture_list > 0 then return end

	self.texture_list = {}

	local menu = MenuHelper:GetMenu('eh_options_menu')
	local multi_hit = menu:item('eh_multi_texture_hit')
	local multi_kill = menu:item('eh_multi_texture_kill')

	for k, v in pairs(file.GetFiles(self.assets_path_custom)) do
		if self:is_texture(self.assets_path_custom .. v) then
			self.texture_list[k] = v
			local c = { _meta = 'option', text_id = v:gsub('\.[^\.]*$', ''), value = k, localize = false }
			multi_hit:add_option(CoreMenuItemOption.ItemOption:new(c))
			multi_kill:add_option(CoreMenuItemOption.ItemOption:new(c))
		end
	end

	multi_hit:_show_options(nil)
	multi_kill:_show_options(nil)

	self:multi_set_choice(multi_hit, (self.settings.hit_texture:gsub('\.[^\.]*$', '')))
	self:multi_set_choice(multi_kill, (self.settings.kill_texture:gsub('\.[^\.]*$', '')))
end

function EnhancedHitmarkers:store_color_settings()
	self.settings.body = string.format('%02x%02x%02x', math.floor(self._data.BR * 100), math.floor(self._data.BG * 100), math.floor(self._data.BB * 100))
	self.settings.head = string.format('%02x%02x%02x', math.floor(self._data.HR * 100), math.floor(self._data.HG * 100), math.floor(self._data.HB * 100))
	self.settings.crit = string.format('%02x%02x%02x', math.floor(self._data.CR * 100), math.floor(self._data.CG * 100), math.floor(self._data.CB * 100))
	self.settings.hcrit = string.format('%02x%02x%02x', math.floor(self._data.CHR * 100), math.floor(self._data.CHG * 100), math.floor(self._data.CHB * 100))
end

function EnhancedHitmarkers:settings_to_data()
	self._data.BR = tonumber(string.sub(self.settings.body, 1, 2), 16) / 100
	self._data.BG = tonumber(string.sub(self.settings.body, 3, 4), 16) / 100
	self._data.BB = tonumber(string.sub(self.settings.body, 5, 6), 16) / 100

	self._data.HR = tonumber(string.sub(self.settings.head, 1, 2), 16) / 100
	self._data.HG = tonumber(string.sub(self.settings.head, 3, 4), 16) / 100
	self._data.HB = tonumber(string.sub(self.settings.head, 5, 6), 16) / 100

	self._data.CR = tonumber(string.sub(self.settings.crit, 1, 2), 16) / 100
	self._data.CG = tonumber(string.sub(self.settings.crit, 3, 4), 16) / 100
	self._data.CB = tonumber(string.sub(self.settings.crit, 5, 6), 16) / 100

	self._data.CHR = tonumber(string.sub(self.settings.hcrit, 1, 2), 16) / 100
	self._data.CHG = tonumber(string.sub(self.settings.hcrit, 3, 4), 16) / 100
	self._data.CHB = tonumber(string.sub(self.settings.hcrit, 5, 6), 16) / 100

	self._data.initial_hit_size_ratio = self.settings.initial_hit_size_ratio
	self._data.initial_kill_size_ratio = self.settings.initial_kill_size_ratio
	self._data.grow_ratio = self.settings.grow_ratio
	self._data.shake = self.settings.shake
	self._data.blend_mode = self.settings.blend_mode
end

function EnhancedHitmarkers:load()
	self:reset()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
	self:settings_to_data()
	self:load_custom_textures()
end

function EnhancedHitmarkers:save()
	local file = io.open(self._data_path, 'w+')
	if file then
		self:store_color_settings()
		file:write(json.encode(self.settings))
		file:close()
	end

	if managers.hud then
		managers.hud:_create_hit_confirm()
	end
end

function EnhancedHitmarkers:get_blend_mode()
	local modes = { 'add', 'normal' }
	return modes[self.settings.blend_mode]
end

function EnhancedHitmarkers:create_hitmarker_bitmap(i, texture, color, initial_size_ratio, x, y, stick_to_bmp)
	local bmp = self._panel:bitmap({
		valign = 'center',
		halign = 'center',
		visible = true,
		texture = texture,
		color = Color(color),
		layer = tweak_data.gui.MOUSE_LAYER - 50,
		blend_mode = self:get_blend_mode()
	})

	local h = bmp:texture_height()
	local w = bmp:texture_width()
	local width = initial_size_ratio * w
	if w * 3 == h then
		bmp:set_texture_rect(0, math.mod(math.min(i, 3) - 1, 4) * w, w, w)
	elseif w * 4 == h then
		bmp:set_texture_rect(0, math.mod(i - 1, 4) * w, w, w)
	end

	bmp:set_size(width, width)
	if x then
		bmp:set_right(x)
		if stick_to_bmp then
			local pad = stick_to_bmp:height() > 75 and 0 or 75 - stick_to_bmp:height()
			bmp:set_top(stick_to_bmp:bottom() + 10 + pad)
		else
			bmp:set_top(self._panel:h() * y)
		end
	else
		bmp:set_right(stick_to_bmp:left() - 10)
		bmp:set_center_y(stick_to_bmp:center_y())
	end

	return bmp
end

function EnhancedHitmarkers:create_hit_bitmaps()
	if not alive(self._panel) or self._bmp_body_hit or not self._bmp_body_kill then
		return
	end

	self._bmp_body_hit = self:create_hitmarker_bitmap(1, self.hit_texture_db, self.settings.body, self.settings.initial_hit_size_ratio, nil, nil, self._bmp_body_kill)
	self._bmp_head_hit = self:create_hitmarker_bitmap(2, self.hit_texture_db, self.settings.head, self.settings.initial_hit_size_ratio, nil, nil, self._bmp_head_kill)
	self._bmp_crit_hit = self:create_hitmarker_bitmap(3, self.hit_texture_db, self.settings.crit, self.settings.initial_hit_size_ratio, nil, nil, self._bmp_crit_kill)
	self._bmp_hcrit_hit = self:create_hitmarker_bitmap(4, self.hit_texture_db, self.settings.hcrit, self.settings.initial_hit_size_ratio, nil, nil, self._bmp_hcrit_kill)
end

function EnhancedHitmarkers:create_kill_bitmaps()
	if not alive(self._panel) or self._bmp_body_kill then
		return
	end

	local x = self._panel:right() - self._panel:w() * 0.37
	self._bmp_body_kill = self:create_hitmarker_bitmap(1, self.kill_texture_db, self.settings.body, self.settings.initial_kill_size_ratio, x, 0.18)
	self._bmp_head_kill = self:create_hitmarker_bitmap(2, self.kill_texture_db, self.settings.head, self.settings.initial_kill_size_ratio, x, 0.315, self._bmp_body_kill)
	self._bmp_crit_kill = self:create_hitmarker_bitmap(3, self.kill_texture_db, self.settings.crit, self.settings.initial_kill_size_ratio, x, 0.45, self._bmp_head_kill)
	self._bmp_hcrit_kill = self:create_hitmarker_bitmap(4, self.kill_texture_db, self.settings.hcrit, self.settings.initial_kill_size_ratio, x, 0.585, self._bmp_crit_kill)
end

function EnhancedHitmarkers:create_all_bitmaps()
	self:create_kill_bitmaps()
	self:create_hit_bitmaps()
end

function EnhancedHitmarkers:remove_bitmaps(bmps)
	if alive(self._panel) then
		for _, bmp in ipairs(bmps) do
			if alive(self[bmp]) then
				self._panel:remove(self[bmp])
			end
			self[bmp] = nil
		end
	end
end

function EnhancedHitmarkers:remove_hit_bitmaps()
	self:remove_bitmaps({ '_bmp_body_hit', '_bmp_head_hit', '_bmp_crit_hit', '_bmp_hcrit_hit' })
end

function EnhancedHitmarkers:remove_kill_bitmaps()
	self:remove_bitmaps({ '_bmp_body_kill', '_bmp_head_kill', '_bmp_crit_kill', '_bmp_hcrit_kill' })
end

function EnhancedHitmarkers:remove_all_bitmaps()
	self:remove_hit_bitmaps()
	self:remove_kill_bitmaps()
end

function EnhancedHitmarkers:create_preview_panel()
	if self._panel or not managers.menu_component then
		return
	end

	self._panel = managers.menu_component._ws:panel():panel()
	self:create_all_bitmaps()
end

function EnhancedHitmarkers:destroy_preview_panel()
	if not alive(self._panel) then
		return
	end

	self._panel:clear()
	self._bmp_body_hit = nil
	self._bmp_body_kill = nil
	self._bmp_head_hit = nil
	self._bmp_head_kill = nil
	self._bmp_crit_hit = nil
	self._bmp_crit_kill = nil
	self._bmp_hcrit_hit = nil
	self._bmp_hcrit_kill = nil

	self._panel:parent():remove(self._panel)
	self._panel = nil
end

function EnhancedHitmarkers:update_preview(bmp, color)
	if alive(self._panel) and alive(bmp) then
		bmp:set_color(Color(color))
	end
end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_EnhancedHitmarkers', function(loc)
	local language_filename

	local modname_to_language = {
		['PAYDAY 2 THAI LANGUAGE Mod'] = 'thai.txt',
	}
	for _, mod in pairs(BLT and BLT.Mods:Mods() or {}) do
		language_filename = mod:IsEnabled() and modname_to_language[mod:GetName()]
		if language_filename then
			break
		end
	end

	if not language_filename then
		for _, filename in pairs(file.GetFiles(EnhancedHitmarkers._path .. 'loc/')) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				language_filename = filename
				break
			end
		end
	end

	if language_filename then
		loc:load_localization_file(EnhancedHitmarkers._path .. 'loc/' .. language_filename)
	end
	loc:load_localization_file(EnhancedHitmarkers._path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_EnhancedHitmarkers', function(menu_manager)
	function MenuCallbackHandler:EnhancedHitmarkersSetRedBody(item)
		EnhancedHitmarkers._data.BR = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_body_hit, EnhancedHitmarkers.settings.body)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_body_kill, EnhancedHitmarkers.settings.body)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetGreenBody(item)
		EnhancedHitmarkers._data.BG = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_body_hit, EnhancedHitmarkers.settings.body)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_body_kill, EnhancedHitmarkers.settings.body)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetBlueBody(item)
		EnhancedHitmarkers._data.BB = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_body_hit, EnhancedHitmarkers.settings.body)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_body_kill, EnhancedHitmarkers.settings.body)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetRedHead(item)
		EnhancedHitmarkers._data.HR = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_head_hit, EnhancedHitmarkers.settings.head)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_head_kill, EnhancedHitmarkers.settings.head)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetGreenHead(item)
		EnhancedHitmarkers._data.HG = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_head_hit, EnhancedHitmarkers.settings.head)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_head_kill, EnhancedHitmarkers.settings.head)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetBlueHead(item)
		EnhancedHitmarkers._data.HB = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_head_hit, EnhancedHitmarkers.settings.head)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_head_kill, EnhancedHitmarkers.settings.head)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetRedCrit(item)
		EnhancedHitmarkers._data.CR = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_crit_hit, EnhancedHitmarkers.settings.crit)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_crit_kill, EnhancedHitmarkers.settings.crit)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetGreenCrit(item)
		EnhancedHitmarkers._data.CG = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_crit_hit, EnhancedHitmarkers.settings.crit)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_crit_kill, EnhancedHitmarkers.settings.crit)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetBlueCrit(item)
		EnhancedHitmarkers._data.CB = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_crit_hit, EnhancedHitmarkers.settings.crit)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_crit_kill, EnhancedHitmarkers.settings.crit)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetRedHCrit(item)
		EnhancedHitmarkers._data.CHR = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_hcrit_hit, EnhancedHitmarkers.settings.hcrit)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_hcrit_kill, EnhancedHitmarkers.settings.hcrit)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetGreenHCrit(item)
		EnhancedHitmarkers._data.CHG = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_hcrit_hit, EnhancedHitmarkers.settings.hcrit)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_hcrit_kill, EnhancedHitmarkers.settings.hcrit)
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetBlueHCrit(item)
		EnhancedHitmarkers._data.CHB = tonumber(item:value())
		EnhancedHitmarkers:store_color_settings()
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_hcrit_hit, EnhancedHitmarkers.settings.hcrit)
		EnhancedHitmarkers:update_preview(EnhancedHitmarkers._bmp_hcrit_kill, EnhancedHitmarkers.settings.hcrit)
	end

	function MenuCallbackHandler:EnhancedHitmarkersChangedFocus(focus)
		if focus then
			local menu = MenuHelper:GetMenu('eh_options_menu')
			local multi_blend_mode = menu:item('eh_multi_set_blend_mode')

			EnhancedHitmarkers:list_available_textures()
			EnhancedHitmarkers:create_preview_panel()
		else
			EnhancedHitmarkers:destroy_preview_panel()
		end
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetTextureHit(item)
		local texture_name = EnhancedHitmarkers.texture_list[item:value()]
		EnhancedHitmarkers.settings.hit_texture = texture_name
		EnhancedHitmarkers:save()
		EnhancedHitmarkers:remove_all_bitmaps()
		EnhancedHitmarkers:load_custom_textures()
		EnhancedHitmarkers:create_all_bitmaps()
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetTextureKill(item)
		local texture_name = EnhancedHitmarkers.texture_list[item:value()]
		EnhancedHitmarkers.settings.kill_texture = texture_name
		EnhancedHitmarkers:save()
		EnhancedHitmarkers:remove_all_bitmaps()
		EnhancedHitmarkers:load_custom_textures()
		EnhancedHitmarkers:create_all_bitmaps()
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetInitialHitSizeRatio(item)
		EnhancedHitmarkers.settings.initial_hit_size_ratio = math.floor(tonumber(item:value()) * 100) / 100
		EnhancedHitmarkers:remove_all_bitmaps()
		EnhancedHitmarkers:create_all_bitmaps()
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetInitialKillSizeRatio(item)
		EnhancedHitmarkers.settings.initial_kill_size_ratio = math.floor(tonumber(item:value()) * 100) / 100
		EnhancedHitmarkers:remove_all_bitmaps()
		EnhancedHitmarkers:create_all_bitmaps()
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetGrowRatio(item)
		EnhancedHitmarkers.settings.grow_ratio = tonumber(item:value())
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetShake(item)
		EnhancedHitmarkers.settings.shake = item:value() == 'on' and true or false
	end

	function MenuCallbackHandler:EnhancedHitmarkersSetBlendMode(item)
		EnhancedHitmarkers.settings.blend_mode = item:value()
		EnhancedHitmarkers:destroy_preview_panel()
		EnhancedHitmarkers:create_preview_panel()
	end

	function MenuCallbackHandler:EnhancedHitmarkersReset(item)
		EnhancedHitmarkers:reset()
		EnhancedHitmarkers:settings_to_data()
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_body_r'] = true}, EnhancedHitmarkers._data.BR)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_body_g'] = true}, EnhancedHitmarkers._data.BG)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_body_b'] = true}, EnhancedHitmarkers._data.BB)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_head_r'] = true}, EnhancedHitmarkers._data.HR)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_head_g'] = true}, EnhancedHitmarkers._data.HG)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_head_b'] = true}, EnhancedHitmarkers._data.HB)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_crit_r'] = true}, EnhancedHitmarkers._data.CR)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_crit_g'] = true}, EnhancedHitmarkers._data.CG)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_crit_b'] = true}, EnhancedHitmarkers._data.CB)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_hcrit_r'] = true}, EnhancedHitmarkers._data.CHR)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_hcrit_g'] = true}, EnhancedHitmarkers._data.CHG)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_colour_hcrit_b'] = true}, EnhancedHitmarkers._data.CHB)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_multi_set_blend_mode'] = true}, EnhancedHitmarkers._data.blend_mode)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_initial_hit_size_ratio'] = true}, EnhancedHitmarkers._data.initial_hit_size_ratio)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_initial_kill_size_ratio'] = true}, EnhancedHitmarkers._data.initial_kill_size_ratio)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_slider_grow_ratio'] = true}, EnhancedHitmarkers._data.grow_ratio)
		MenuHelper:ResetItemsToDefaultValue(item, {['eh_toggle_shake'] = true}, EnhancedHitmarkers._data.shake)
		EnhancedHitmarkers:save()
	end

	function MenuCallbackHandler:EnhancedHitmarkersSave()
		EnhancedHitmarkers:save()
		EnhancedHitmarkers.texture_list = {}
	end

	EnhancedHitmarkers:initialize_texture_folder()
	EnhancedHitmarkers:load()
	MenuHelper:LoadFromJsonFile(EnhancedHitmarkers._path .. 'menu/options.txt', EnhancedHitmarkers, EnhancedHitmarkers._data)
end)
