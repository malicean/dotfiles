local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

function MultiProfileManager:ddi_update_other_profiles(category, old_data, new_data)
	local ctg = DragDropInventory.ctg2ctg[category]
	if not ctg then
		return
	end

	local indexed_new_data = {}
	for i, item in pairs(new_data) do
		indexed_new_data[item] = i
	end

	for i, profile in ipairs(self._global._profiles) do
		if i ~= self._current_profile then
			local previous_index = profile[ctg]
			local item = old_data[previous_index]
			local current_index = indexed_new_data[item]
			if current_index ~= previous_index then
				profile[ctg] = current_index
			end
		end
	end

	local ctg_slot = ctg .. '_slot'
	local function update_henchmen_profile(data)
		for _, v in ipairs(data) do
			if type(v) == 'table' then
				local previous_index = v[ctg_slot]
				local item = old_data[previous_index]
				local current_index = indexed_new_data[item]
				if current_index ~= previous_index then
					v[ctg_slot] = current_index
				end
			end
		end
	end

	if Global.blackmarket_manager._selected_henchmen then
		update_henchmen_profile(Global.blackmarket_manager._selected_henchmen)
	end
	for _, profile in ipairs(self._global._profiles) do
		if profile and profile.henchmen_loadout then
			update_henchmen_profile(profile.henchmen_loadout)
		end
	end
end

function MultiProfileManager:ddi_swap_item(category, from_slot, to_slot)
	local ctg = DragDropInventory.ctg2ctg[category]
	if not ctg then
		return
	end

	for i, profile in ipairs(self._global._profiles) do
		if i ~= self._current_profile then
			if profile[ctg] == from_slot then
				profile[ctg] = to_slot
			elseif profile[ctg] == to_slot then
				profile[ctg] = from_slot
			end
		end
	end

	local ctg_slot = ctg .. '_slot'
	local function update_henchmen_profile(data)
		for _, v in ipairs(data) do
			if type(v) == 'table' then
				if v[ctg_slot] == from_slot then
					v[ctg_slot] = to_slot
				elseif v[ctg_slot] == to_slot then
					v[ctg_slot] = from_slot
				end
			end
		end
	end

	if Global.blackmarket_manager._selected_henchmen then
		update_henchmen_profile(Global.blackmarket_manager._selected_henchmen)
	end
	for _, profile in ipairs(self._global._profiles) do
		if profile and profile.henchmen_loadout then
			update_henchmen_profile(profile.henchmen_loadout)
		end
	end
end
