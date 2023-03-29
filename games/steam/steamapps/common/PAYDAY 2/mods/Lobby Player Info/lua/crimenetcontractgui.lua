local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local lpi_original_crimenetcontractgui_mousepressed = CrimeNetContractGui.mouse_pressed
function CrimeNetContractGui:mouse_pressed(o, button, x, y)
	if LobbyPlayerInfo.settings.inspect_mod_on_google then
		if self._mod_items and self._mods_tab and self._mods_tab:is_active() and button == Idstring('0') then
			for _, item in ipairs(self._mod_items) do
				if item[1]:inside(x, y) then
					Steam:overlay_activate('url', LobbyPlayerInfo:inspect_mod_url(item[1]:name()))
					return
				end
			end
		end
	end

	return lpi_original_crimenetcontractgui_mousepressed(self, o, button, x, y)
end
