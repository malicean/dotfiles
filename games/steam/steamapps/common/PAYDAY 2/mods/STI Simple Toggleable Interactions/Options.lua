if STI then return end

_G.STI = _G.STI or {}
STI._mod_path = ModPath
STI._save_path = SavePath .. 'sti.json'
STI.settings = {
	interaction = true,
	min_timer_duration = 0,
	interact_interrupt_key = 1,
	equipment = true,
	mask = true
}

function STI:load()
	local file = io.open(self._save_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
end

STI:load()

function STI:save()
	local file = io.open(self._save_path, 'w')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_STI', function(loc)
	-- need to add a real loading mechanism if translations are added
	loc:load_localization_file(STI._mod_path .. 'loc/english.json')
end)

Hooks:Add('MenuManagerInitialize', 'MenuManageInitialize_STI', function(menu_manager)
	MenuCallbackHandler.STISave = function(this, item)
		STI:save()
	end
	MenuCallbackHandler.STIToggleOption = function(this, item)
		STI.settings[item:name()] = (item:value() == 'on')
	end
	MenuCallbackHandler.STIGenericOption = function(this, item)
		STI.settings[item:name()] = item:value()
	end
	MenuHelper:LoadFromJsonFile(STI._mod_path .. 'options.json', STI, STI.settings)
end)


