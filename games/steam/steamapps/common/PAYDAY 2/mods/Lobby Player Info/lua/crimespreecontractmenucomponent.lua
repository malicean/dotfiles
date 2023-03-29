local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if not LobbyPlayerInfo.settings.show_host_mods_in_crimespree_contract then
	return
end

local lpi_original_crimespreecontractmenucomponent_setup = CrimeSpreeContractMenuComponent._setup
function CrimeSpreeContractMenuComponent:_setup()
	lpi_original_crimespreecontractmenucomponent_setup(self)

	-- see CrimeNetContractGui:init()
	local job_data = self._data
	local padding = tweak_data.gui.crime_net.contract_gui.padding
	local half_padding = 0.5 * padding
	local double_padding = 2 * padding
	local text_w = tweak_data.gui.crime_net.contract_gui.text_width
	local contact_w = tweak_data.gui.crime_net.contract_gui.contact_width
	local contact_h = contact_w / 1.7777777777777777

	self.lpi_tabs = {}
	self._pages = {}
	self._active_page = nil
	local tabs_panel = self._contract_panel:panel({
		y = 10,
		w = contact_w,
		h = contact_h,
		x = text_w + 20
	})
	-- tabs_panel:set_top((self._briefing_len_panel and self._briefing_len_panel:bottom() or contact_text:bottom()) + 10)
	tabs_panel:set_bottom(494)
	tabs_panel:set_visible(false)
	local pages_panel = self._contract_panel:panel({})
	pages_panel:set_visible(false)

	local function add_tab(text_id)
		local prev_tab = self.lpi_tabs[#self.lpi_tabs]
		local tab_item = MenuGuiSmallTabItem:new(#self.lpi_tabs + 1, text_id, nil, self, 0, tabs_panel)
		table.insert(self.lpi_tabs, tab_item)
		if prev_tab then
			tab_item._page_panel:set_left(prev_tab:next_page_position())
		end
		if #self.lpi_tabs == 1 then
			tab_item:set_active(true)
			self._active_page = 1
			tabs_panel:set_visible(true)
			pages_panel:set_visible(true)
			tabs_panel:set_h(tab_item._page_panel:bottom())
			pages_panel:set_size(contact_w, contact_h - tabs_panel:h())
			pages_panel:set_lefttop(tabs_panel:left(), tabs_panel:bottom() - 2)
			BoxGuiObject:new(pages_panel, {sides = {
				1,
				1,
				2,
				1
			}})
			managers.menu:active_menu().input:set_force_input(true)
		end
		local page_panel = pages_panel:panel({})
		page_panel:set_visible(tab_item:is_active())
		table.insert(self._pages, page_panel)
		return page_panel
	end

	if job_data.mods then
		local mods_presence = job_data.mods
		if mods_presence and mods_presence ~= "" and mods_presence ~= "1" then
			local content_panel = add_tab("menu_cn_game_mods")
			self._mods_tab = self.lpi_tabs[#self.lpi_tabs]
			self._mods_scroll = ScrollablePanel:new(content_panel, "mods_scroll", {padding = 0})
			self._mod_items = {}
			local _y = 7
			local add_back = true
			local function add_line(id, text, ignore_back)
				local canvas = self._mods_scroll:canvas()
				if add_back and not ignore_back then
					canvas:rect({
						x = 8,
						layer = -1,
						y = _y,
						h = tweak_data.menu.pd2_small_font_size,
						w = canvas:w() - 18,
						color = Color.black:with_alpha(0.7)
					})
				end
				add_back = not add_back
				text = string.upper(text)
				local left_text = canvas:text({
					align = "left",
					name = id,
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					text = text,
					x = padding,
					y = _y,
					h = tweak_data.menu.pd2_small_font_size,
					w = canvas:w() - double_padding,
					color = Color(0.8, 0.8, 0.8)
				})
				local highlight_text = canvas:text({
					blend_mode = "add",
					align = "left",
					visible = false,
					name = id,
					font = tweak_data.menu.pd2_small_font,
					font_size = tweak_data.menu.pd2_small_font_size,
					text = text,
					x = padding,
					y = _y,
					h = tweak_data.menu.pd2_small_font_size,
					w = canvas:w() - double_padding,
					color = tweak_data.screen_colors.button_stage_2
				})
				_y = left_text:bottom() + 2
				return left_text, highlight_text
			end
			local splits = string.split(mods_presence, "|")
			for i = 1, #splits, 2 do
				local text, highlight = add_line(splits[i + 1] or "", splits[i] or "")
				table.insert(self._mod_items, {
					text,
					highlight
				})
			end
			add_line("spacer", "", true)
			self._mods_scroll:update_canvas_size()
		end
	end
end

local lpi_original_crimespreecontractmenucomponent_mousemoved = CrimeSpreeContractMenuComponent.mouse_moved
function CrimeSpreeContractMenuComponent:mouse_moved(o, x, y)
	local used, pointer = nil
	if self._mod_items and self._mods_tab and self._mods_tab:is_active() then
		for _, item in ipairs(self._mod_items) do
			if item[1]:inside(x, y) and not used then
				pointer = "link"
				used = true

				item[1]:set_visible(false)
				item[2]:set_visible(true)
			else
				item[1]:set_visible(true)
				item[2]:set_visible(false)
			end
		end
	end
	if used then
		return used, pointer
	end

	if self._active_page then
		for k, tab_item in pairs(self.lpi_tabs) do
			if not tab_item:is_active() and tab_item:inside(x, y) then
				return true, "link"
			end
		end
	end

	return lpi_original_crimespreecontractmenucomponent_mousemoved(self, o, x, y)
end

local lpi_original_crimespreecontractmenucomponent_mousepressed = CrimeSpreeContractMenuComponent.mouse_pressed
function CrimeSpreeContractMenuComponent:mouse_pressed(button, x, y)
	if self._mod_items and self._mods_tab and self._mods_tab:is_active() and button == Idstring("0") then
		for _, item in ipairs(self._mod_items) do
			if item[1]:inside(x, y) then
				Steam:overlay_activate("url", LobbyPlayerInfo:inspect_mod_url(item[1]:name()))
				return true
			end
		end
	end

	return lpi_original_crimespreecontractmenucomponent_mousepressed(self, button, x, y)
end

local lpi_original_crimespreecontractmenucomponent_mousewheelup = CrimeSpreeContractMenuComponent.mouse_wheel_up
function CrimeSpreeContractMenuComponent:mouse_wheel_up(x, y)
	lpi_original_crimespreecontractmenucomponent_mousewheelup(self, x, y)
	if self._mods_scroll then
		self._mods_scroll:scroll(x, y, 1)
	end
end

local lpi_original_crimespreecontractmenucomponent_mousewheeldown = CrimeSpreeContractMenuComponent.mouse_wheel_down
function CrimeSpreeContractMenuComponent:mouse_wheel_down(x, y)
	lpi_original_crimespreecontractmenucomponent_mousewheeldown(self, x, y)
	if self._mods_scroll then
		self._mods_scroll:scroll(x, y, -1)
	end
end
