local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_LobbyPlayerInfo', function(loc)
	local language_filename

	if BLT.Localization._current == 'cht' or BLT.Localization._current == 'zh-cn' then
		LobbyPlayerInfo._abbreviation_length_v = 2
	end

	if not language_filename then
		local modname_to_language = {
			['PAYDAY 2 THAI LANGUAGE Mod'] = 'thai.txt',
		}
		for _, mod in pairs(BLT and BLT.Mods:Mods() or {}) do
			language_filename = mod:IsEnabled() and modname_to_language[mod:GetName()]
			if language_filename then
				LobbyPlayerInfo._abbreviation_length_v = 2
				break
			end
		end
	end

	if not language_filename then
		for _, filename in pairs(file.GetFiles(LobbyPlayerInfo._path .. 'loc/')) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				language_filename = filename
				break
			end
		end
	end

	if language_filename then
		loc:load_localization_file(LobbyPlayerInfo._path .. 'loc/' .. language_filename)
	end
	loc:load_localization_file(LobbyPlayerInfo._path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_LobbyPlayerInfo', function(menu_manager)

	local lpi_original_menucallbackhandler_inspectmod = MenuCallbackHandler.inspect_mod
	function MenuCallbackHandler:inspect_mod(item)
		if LobbyPlayerInfo.settings.inspect_mod_on_google then
			if item:parameters().mod_id then
				Steam:overlay_activate('url', LobbyPlayerInfo:inspect_mod_url(item:parameters().mod_id))
			end
		else
			return lpi_original_menucallbackhandler_inspectmod(self, item)
		end
	end

	function MenuCallbackHandler:lpi_checkbox_hub(item)
		LobbyPlayerInfo.settings[item:name()] = item:value() == 'on'
	end

	function MenuCallbackHandler:lpi_multi_hub(item)
		LobbyPlayerInfo.settings[item:name()] = item:value()
	end

	function MenuCallbackHandler:LobbyPlayerInfoTeamSkillsMode(item)
		LobbyPlayerInfo.settings.team_skills_mode = item:value()
		if managers.menu_component._contract_gui then
			LPITeamBox:Update()
		end
	end

	function MenuCallbackHandler:LobbyPlayerInfoSetLayout(item)
		LobbyPlayerInfo.settings.skills_layout = item:value()
		local contract_gui = managers.menu_component._contract_gui
		if contract_gui then
			if contract_gui._peers_skills then
				for _, obj in pairs(contract_gui._peers_skills) do
					obj:parent():remove(obj)
				end
				contract_gui._peers_skills = {}
			else
				for peer_id, chardata in pairs(contract_gui._peer_panels) do
					if chardata._peer_skills then
						chardata._peer_skills:parent():remove(chardata._peer_skills)
						chardata._peer_skills = LobbyPlayerInfo:CreatePeerSkills(chardata._panel)
					end
				end
			end
		end
	end

	function MenuCallbackHandler:LobbyPlayerInfoResetToDefaultValues(item)
		LobbyPlayerInfo:ResetToDefaultValues()
		for k, v in pairs(LobbyPlayerInfo.settings) do
			MenuHelper:ResetItemsToDefaultValue(item, {[k] = true}, v)
		end
	end

	function MenuCallbackHandler:LobbyPlayerInfoSave(item)
		LobbyPlayerInfo:Save()
	end

	MenuHelper:LoadFromJsonFile(LobbyPlayerInfo._path .. 'menu/options.txt', LobbyPlayerInfo, LobbyPlayerInfo.settings)

end)

local lpi_original_menumanager_pushtotalk = MenuManager.push_to_talk
function MenuManager:push_to_talk(enabled)
	lpi_original_menumanager_pushtotalk(self, enabled)
	if managers.network and managers.network.voice_chat and managers.network.voice_chat._enabled and managers.network:session() then
		if table.size(managers.network:session():peers()) > 0 then
			managers.network.voice_chat._users_talking[managers.network:session():local_peer():id()] = { active = enabled }
		end
	end
end
