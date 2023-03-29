-- ****************** HEY, LISTEN!!!! ******************
--If you're here because you want to change the mod to silent mode, you are in the wrong place.
--You should use the Mod Options menu to change this mod's settings. 
--If you do not have a Mod Options menu, you must upgrade from BLT to SuperBLT: https://superblt.znix.xyz/

_G.MethHelperUpdated = MethHelperUpdated or {}
MethHelperUpdated.settings = {
	enabled = true,
	ingred_chatmode = 1,
	ingred_hintmode = true,
	ingred_repeat = false,
	added_chatmode = 1,
	added_hintmode = false,
	done_chatmode = 1,
	done_hintmode = false,
	fail_chatmode = 3,
	fail_hintmode = true,
	language_name = "en.txt",
	_language_index = 2 --don't bother changing this, it doesn't do anything except VISUALLY change which language is selected in the multiple choice menu
}

MethHelperUpdated.populated_languages_menu = false
MethHelperUpdated.languages = {} --populated later

MethHelperUpdated.path = ModPath
MethHelperUpdated.loc_path = MethHelperUpdated.path .. "loc/"
MethHelperUpdated.save_path = SavePath .. "methhelperupdated.txt"

MethHelperUpdated._last_ingredient = "Fish-shaped volatile organic compounds and sediment-shaped sediment" --placeholder

function MethHelperUpdated:IsEnabled()
	return self.settings.enabled
end

function MethHelperUpdated:GetLanguage()
	return self.settings.language_name
end

function MethHelperUpdated:DebugEnabled() 
	return false
end

function MethHelperUpdated:ShouldRepeatIngredients()
	return self.settings.ingred_repeat
end

function MethHelperUpdated:GetOutputType(dialog_id)
	local s = self.settings
	local chatmode = s[dialog_id .. "_chatmode"] or 3
	local hintmode = s[dialog_id .. "_hintmode"] or false

	return chatmode,hintmode
end

function MethHelperUpdated:Toggle_Enabled(enabled)
	if enabled == nil then 
		self.settings.enabled = not self.settings.enabled
	else
		self.settings.enabled = enabled
	end
	return self.settings.enabled
end

function MethHelperUpdated:LocalizeLine(id)
	return managers.localization:text("methhelperupdated_" .. tostring(id))
end

function MethHelperUpdated:Load()
	local file = io.open(self.save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:Save()
	end
end

function MethHelperUpdated:Save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function MethHelperUpdated:LoadLanguageFiles()
	for i,filename in ipairs(SystemFS:list(self.loc_path)) do 
		local file = io.open(self.loc_path .. filename, "r")
		if file then
			local localized_strings = json.decode(file:read("*all"))
			local lang_name = localized_strings and (type(localized_strings) == "table") and localized_strings.methhelperupdated_language_name
			if lang_name then 
				self.languages[filename] = {
					index = i,
					localized_language_name = lang_name,
					localization = localized_strings
				}
			end
		
		end
		if filename == self:GetLanguage() then 
			self.settings._language_index = i
			-- language order is not guaranteed- particularly if a new language is added which interferes with the alphabetical order-
			-- which is why the filename is saved and not the index number of the language,
			-- and the index number is "generated" on load instead of being written here in settings
		end
	end
end

function MethHelperUpdated:LoadLanguage(localizationmanager,user_language)
	localizationmanager = localizationmanager or managers.localization
	if localizationmanager then 
		user_language = user_language or self:GetLanguage()
		local language_data = user_language and self.languages[user_language]
		local ization = language_data and language_data.localization  --get it? local-ization? hahahahaha please clap
		if ization then 
			if self:DebugEnabled() then 
				log("MethHelperUpdated: Loading localization for " .. user_language)
			end
			self.settings._language_index = language_data.index
			localizationmanager:add_localized_strings(ization)
		end
	elseif self:DebugEnabled() then 
		log("MethHelperUpdated: ERROR! Failed to find LocalizationManager!")
	end
end

MethHelperUpdated:Load() --load settings; this should be before menu creation 
MethHelperUpdated:LoadLanguageFiles()

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_MethHelperUpdated",
	callback(MethHelperUpdated,MethHelperUpdated,"LoadLanguage")
)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_MethHelperUpdated", function(menu_manager)
	
	MenuCallbackHandler.callback_methhelperupdated_toggle_enabled = function(self,item)
		local value = item:value() == "on"
		MethHelperUpdated:Toggle_Enabled(value)
		MethHelperUpdated:Save()
	end
	
	MenuCallbackHandler.callback_methhelperupdated_refocus = function(self)
		if MethHelperUpdated.populated_languages_menu then
			return
		end
		
		local menu_item = MenuHelper:GetMenu("methhelperupdated_options") or {_items = {}}
		for _,item in pairs(menu_item._items) do 
			if item._parameters and item._parameters.name == "methhelperupdated_select_language" then 
				for lang_name,lang_data in pairs(MethHelperUpdated.languages) do 
					item:add_option(
						CoreMenuItemOption.ItemOption:new(
							{
								_meta = "option",
								text_id = lang_data.localized_language_name,
								value = lang_data.index,
								localize = false
							}
						)
					)
				end
				item:set_value(MethHelperUpdated.settings._language_index)
				break
			end
		end	
		MethHelperUpdated.populated_languages_menu = true
	end
	
	MenuCallbackHandler.callback_methhelperupdated_select_language = function(self,item) --populate multiplechoice with profile options
		for lang_name,lang_data in pairs(MethHelperUpdated.languages) do 
			if lang_data.index == tonumber(item:value()) then 
				MethHelperUpdated.settings.language_name = lang_name
				MethHelperUpdated:Save()
				MethHelperUpdated:LoadLanguage(nil,lang_name)
				return
			end
		end
	end	
	
	MenuCallbackHandler.callback_methhelperupdated_keybind_toggle = function(self)
		local value = MethHelperUpdated:Toggle_Enabled()
		if managers.hud then 
			managers.hud:show_hint({text = MethHelperUpdated:LocalizeLine("toggled_" .. tostring(value))})
		end
		--don't save from keybind
	end
	
	MenuCallbackHandler.callback_methhelperupdated_ingred_chatmode = function(self,item)
		local value = tonumber(item:value())
		MethHelperUpdated.settings.ingred_chatmode = value
		MethHelperUpdated:Save()
	end
	MenuCallbackHandler.callback_methhelperupdated_ingred_hintmode = function(self,item)
		local value = item:value() == "on"
		MethHelperUpdated.settings.ingred_hintmode = value
		MethHelperUpdated:Save()
	end
	MenuCallbackHandler.callback_methhelperupdated_ingred_repeat = function(self,item)
		local value = item:value() == "on"
		MethHelperUpdated.settings.ingred_repeat = value
		MethHelperUpdated:Save()
	end
	
	MenuCallbackHandler.callback_methhelperupdated_added_chatmode = function(self,item)
		local value = tonumber(item:value())
		MethHelperUpdated.settings.added_chatmode = value
		MethHelperUpdated:Save()
	end
	MenuCallbackHandler.callback_methhelperupdated_added_hintmode = function(self,item)
		local value = item:value() == "on"
		MethHelperUpdated.settings.added_hintmode = value
		MethHelperUpdated:Save()
	end
	
	MenuCallbackHandler.callback_methhelperupdated_done_chatmode = function(self,item)
		local value = tonumber(item:value())
		MethHelperUpdated.settings.done_chatmode = value
		MethHelperUpdated:Save()
	end
	MenuCallbackHandler.callback_methhelperupdated_done_hintmode = function(self,item)
		local value = item:value() == "on"
		MethHelperUpdated.settings.done_hintmode = value
		MethHelperUpdated:Save()
	end
	
	MenuCallbackHandler.callback_methhelperupdated_fail_chatmode = function(self,item)
		local value = tonumber(item:value())
		MethHelperUpdated.settings.fail_chatmode = value
		MethHelperUpdated:Save()
	end
	MenuCallbackHandler.callback_methhelperupdated_fail_hintmode = function(self,item)
		local value = item:value() == "on"
		MethHelperUpdated.settings.fail_hintmode = value
		MethHelperUpdated:Save()
	end
	
	MenuCallbackHandler.callback_methhelperupdated_close = function(self)
--		MethHelperUpdated:Save() --redundant since the mod saves after any setting change
	end
	MenuHelper:LoadFromJsonFile(MethHelperUpdated.path .. "menu/options.txt", MethHelperUpdated, MethHelperUpdated.settings)

end)