local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local function sort_mod_list(mods_presence)
	if mods_presence and mods_presence ~= '' and mods_presence ~= '1' then
		local mod_items = {}
		local splits = string.split(mods_presence, '|')
		for i = 1, #splits, 2 do
			local text, highlight = splits[i + 1] or '', splits[i] or ''

			if text == '' and highlight ~= '' then
				text = highlight
			elseif text ~= '' and highlight == '' then
				highlight = text
			end

			table.insert(mod_items, { highlight, text })
		end

		table.sort(mod_items, function(a, b)
			return string.lower(a[1]) < string.lower(b[1])
		end)

		for k, v in ipairs(mod_items) do
			mod_items[k] = table.concat(v, '|')
		end
		mods_presence = table.concat(mod_items, '|')
	end
	return mods_presence
end

local as_original_crimenetcontractgui_init = CrimeNetContractGui.init
function CrimeNetContractGui:init(ws, fullscreen_ws, node)
	local job_data = node:parameters().menu_component_data
	job_data.mods = sort_mod_list(job_data.mods)

	as_original_crimenetcontractgui_init(self, ws, fullscreen_ws, node)
end

local as_original_crimespreecontractmenucomponent_setup = CrimeSpreeContractMenuComponent._setup
function CrimeSpreeContractMenuComponent:_setup()
	local job_data = self._data
	job_data.mods = sort_mod_list(job_data.mods)

	as_original_crimespreecontractmenucomponent_setup(self)
end
