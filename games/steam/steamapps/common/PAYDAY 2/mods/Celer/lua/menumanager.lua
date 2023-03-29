local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_Celer', function(loc)
	local language_filename

	for _, filename in pairs(file.GetFiles(Celer._path .. 'loc/')) do
		local str = filename:match('^(.*).txt$')
		if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
			language_filename = filename
			break
		end
	end

	if language_filename then
		loc:load_localization_file(Celer._path .. 'loc/' .. language_filename)
	end
	loc:load_localization_file(Celer._path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_Celer', function(menu_manager)
	MenuCallbackHandler.CelerMenuCheckboxClbk = function(this, item)
		Celer.settings[item:name()] = item:value() == 'on'
	end

	MenuCallbackHandler.CelerMenuSetMaxActiveOccludersNr = function(this, item)
		Celer:set_max_active_occluders_nr(item:value())
	end

	MenuCallbackHandler.CelerSave = function(this, item)
		Celer:save()
	end

	MenuHelper:LoadFromJsonFile(Celer._path .. 'menu/options.txt', Celer, Celer.settings)

	Hooks:Add('MenuManagerBuildCustomMenus', 'MenuManagerBuildCustomMenus_Celer', function(menu_manager, nodes)
		nodes.cel_options_menu:parameters().modifier = {CelerMenuCreator.modify_node}
	end)
end)

DelayedCalls:Add('DelayedMod_LocalizationManager_recur_text', 0, function()
	local cel_localizationmanager_text = LocalizationManager.text
	function LocalizationManager:text(str, macros)
		local result = cel_localizationmanager_text(self, str, macros)

		if self._custom_localizations[str] then
			local ms = {}
			for m in result:gmatch('%$([%w_-]+)') do
				if self._custom_localizations[m] or Localizer:exists(Idstring(m)) then
					table.insert(ms, m)
				end
			end

			table.sort(ms, function(a, b)
				return a:len() > b:len()
			end)

			for _, m in ipairs(ms) do
				result = result:gsub('$' .. m, self:text(m))
			end
		end

		return result
	end
end)

CelerMenuCreator = CelerMenuCreator or class()
function CelerMenuCreator.modify_node(node)
	local old_items = node:items()

	node:clean_items()

	node:add_item(table.remove(old_items, 1))
	node:add_item(table.remove(old_items, 1))

	table.sort(old_items, function(a, b)
		local a = managers.localization:text(a:parameters().text_id)
		local b = managers.localization:text(b:parameters().text_id)
		return a < b
	end)
	for _, item in pairs(old_items) do
		node:add_item(item)
	end

	return node
end
