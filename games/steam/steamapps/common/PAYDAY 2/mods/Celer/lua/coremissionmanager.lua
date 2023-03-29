local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

_G.Celer = _G.Celer or {}
Celer._path = ModPath
Celer._data_path = SavePath .. 'Celer.txt'
Celer.occluders = {}
Celer.settings = {
	max_active_occluders_nr = World:occlusion_manager():max_occluder_tests(),
	patch_duplicate_unit_ids = true, -- *SIGHS*
	map_change_bex = true,
	map_change_big = true,
	map_change_born = true,
	map_change_bph = true,
	map_change_brb = true,
	map_change_chas = true,
	map_change_chill_combat = true,
	map_change_dah = true,
	map_change_des = true,
	map_change_dinner = true,
	map_change_fex = true,
	map_change_firestarter_1 = true,
	map_change_friend = true,
	map_change_hox_1 = true,
	map_change_hox_2 = true,
	map_change_kenaz = true,
	map_change_mex = true,
	map_change_moon = true,
	map_change_mus = true,
	map_change_nmh = true,
	map_change_peta = true,
	map_change_pex = true,
	map_change_rvd2 = true,
	map_change_sah = true,
	map_change_vit = true,
}

function Celer:set_max_active_occluders_nr(value)
	value = value and math.round(value) or self.settings.max_active_occluders_nr
	self.settings.max_active_occluders_nr = value
	World:occlusion_manager():set_max_occluder_tests(value)
end

function Celer:set_holdout_settings()
	self.settings.map_change_skm_bex = self.settings.map_change_bex
	self.settings.map_change_skm_big2 = self.settings.map_change_big
	self.settings.map_change_skm_cas = self.settings.map_change_kenaz
	self.settings.map_change_skm_mus = self.settings.map_change_mus
end

function Celer:load()
	local file = io.open(self._data_path, 'r')
	if file then
		for k, v in pairs(json.decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
	self:set_holdout_settings()
	self:set_max_active_occluders_nr()
end

function Celer:save()
	self:set_holdout_settings()
	local file = io.open(self._data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function Celer:get_level_id()
	local level_id = Global.game_settings and Global.game_settings.level_id or ''
	level_id = level_id:gsub('_night$', ''):gsub('_day$', '')
	return level_id
end

function Celer:get_autogen_varname()
	return 'cel_tmp_unit_groups_ids'
end

function Celer:get_autogen_filename()
	return self._path .. 'auto/' .. self:get_level_id() .. '.lua'
end

function Celer:load_autogen_unit_groups()
	local filename = self:get_autogen_filename()
	if not SystemFS:exists(filename) then
		return {}
	end

	dofile(filename)
	local result = _G[self:get_autogen_varname()]
	_G[self:get_autogen_varname()] = nil

	return result
end

local occ_path = 'units/payday2/mockup/'
local occ_basename = 'occluder_plane_'

function Celer:load_occluder(size)
	if not managers.dyn_resource then
		DelayedCalls:Add('DelayedCeler_loadoccluder_' .. size, 0, function()
			self:load_occluder(size)
		end)
		return
	end

	local occ_name = occ_basename .. size
	local ids_path_name = Idstring(occ_path .. occ_name)
	local dyn_res_pack = managers.dyn_resource.DYN_RESOURCES_PACKAGE
	if managers.dyn_resource:has_resource(Idstring('unit'), ids_path_name, dyn_res_pack) then
		return
	end

	local clbk = function()
		self:load_occluder(size)
	end

	if not managers.dyn_resource:has_resource(Idstring('material_config'), Idstring('units/payday2/mockup/occluder_plane'), dyn_res_pack) then
		DB:create_entry(
			Idstring('material_config'),
			Idstring('units/payday2/mockup/occluder_plane'),
			self._path .. 'assets/occluder_plane.material_config'
		)
		managers.dyn_resource:load(Idstring('material_config'), Idstring('units/payday2/mockup/occluder_plane'), dyn_res_pack, clbk)
		return
	end

	if size == '4x8' or size == '8x8' or size == '16x8' or size == '16x16' then
		-- qued
	elseif not managers.dyn_resource:has_resource(Idstring('model'), ids_path_name, dyn_res_pack) then
		DB:create_entry(
			Idstring('model'),
			ids_path_name,
			string.format('%sassets/%s.model', self._path, occ_name)
		)
		managers.dyn_resource:load(Idstring('model'), ids_path_name, dyn_res_pack, clbk)
		return
	end

	for _, ext in ipairs({ 'object', 'unit' }) do
		DB:create_entry(
			Idstring(ext),
			ids_path_name,
			string.format('%sassets/%s.%s', self._path, occ_name, ext)
		)
	end

	managers.dyn_resource:load(Idstring('unit'), ids_path_name, dyn_res_pack)
end

function Celer:spawn_occluder(size, pos, rot, reversed)
	if not managers.dyn_resource then
		DelayedCalls:Add('DelayedCeler_spawnoccluder_' .. size .. tostring(pos) .. tostring(rot) .. tostring(reversed), 0, function()
			self:spawn_occluder(size, pos, rot, reversed)
		end)
		return 'pending'
	end

	local name = occ_path .. occ_basename .. size
	if not managers.dyn_resource:has_resource(Idstring('unit'), Idstring(name), managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		self:load_occluder(size)
	end

	if not managers.dyn_resource:is_resource_ready(Idstring('unit'), Idstring(name), managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
		DelayedCalls:Add('DelayedCeler_spawnoccluder_' .. size .. tostring(pos) .. tostring(rot) .. tostring(reversed), 0, function()
			self:spawn_occluder(size, pos, rot, reversed)
		end)
		return 'pending'
	end

	if reversed then
		local v
		if size == '3x6'
			or size == '12x6'
		then
			v = Vector3(0, 0, 600)
		elseif size == '4x8'
			or size == '12x4'
		then
			v = Vector3(0, 0, 400)
		elseif size == '5x8'
			or size == '6x8'
			or size == '7x8'
			or size == '8x8'
			or size == '9x8'
			or size == '10x8'
			or size == '11x8'
			or size == '12x8'
			or size == '13x8'
			or size == '14x8'
			or size == '15x8'
			or size == '16x8'
		then
			v = Vector3(0, 0, 800)
		elseif size == '12x12' then
			v = Vector3(0, 0, 1200)
		elseif size == '16x10' then
			v = Vector3(0, 0, 1000)
		elseif size == '16x14' then
			v = Vector3(0, 0, 1400)
		elseif size == '16x15' then
			v = Vector3(0, 0, 1500)
		elseif size == '16x16'
			or size == '18x16'
			or size == '20x16'
			or size == '24x16'
			or size == '32x16'
		then
			v = Vector3(0, 0, 1600)
		elseif size == '20x20'
			or size == '32x20'
		then
			v = Vector3(0, 0, 2000)
		elseif size == '32x32' then
			v = Vector3(0, 0, 3200)
		end
		pos = pos + v:rotate_with(rot)
		mrotation.set_yaw_pitch_roll(rot, rot:yaw(), rot:pitch() + 180, rot:roll())
	end

	local unit = safe_spawn_unit(name, pos, rot)
	if unit then
		unit:set_visible(not not self.occluder_visibility)
		table.insert(self.occluders, unit)
	end

	return unit
end

function Celer:set_occluder_visibility(state)
	self.occluder_visibility = state

	for i, occluder in pairs(self.occluders) do
		if alive(occluder) then
			occluder:set_visible(state)
		end
	end
end

Celer:load()

core:module('CoreMissionManager')
core:import('CoreTable')

if not _G.Iter and Network:is_client() then
	function MissionScript:load(data)
		local state = data[self._name]
		if self._element_groups.ElementInstancePoint then
			for _, element in ipairs(self._element_groups.ElementInstancePoint) do
				local id = element:id()
				if state[id] then
					self._elements[id]:load(state[id])
					state[id] = nil
				end
			end
		end

		for id, mission_state in pairs(state) do
			local element = self._elements[id]
			if element and type(element.load) == 'function' then
				element:load(mission_state)
			end
		end
	end
end

local level_id = _G.Celer:get_level_id()
local cel_original_missionmanager_addscript = MissionManager._add_script

if not _G.Celer.settings['map_change_' .. level_id] then
	-- qued

elseif level_id == 'chas' then

	function MissionManager:_add_script(data)
		for _, element in pairs(data.elements) do
			if element.id == 101741 or element.id == 101744 or element.id == 101748 then
				element.values.enabled = false
			end
		end

		cel_original_missionmanager_addscript(self, data)
	end

elseif level_id == 'chill_combat' then

	_G.Celer.delete_instances = {
		aldstone_001 = true,
		chill_bodhi_01_001 = true,
		chill_dragan_01_001 = true,
		chill_friend_001 = true,
		chill_hockey_game_001 = true,
		chill_jacket_01_001 = true,
		chill_punching_bag_001 = true,
		chill_sokol_01_001 = true,
		chill_vault_01_001 = true,
		chill_wick_kill_room_001 = true,
		chill_wick_target_dummy_01_001 = true,
		chill_wick_target_dummy_01_002 = true,
		chill_wick_target_dummy_01_003 = true,
		chill_wick_target_dummy_01_004 = true,
		chill_wick_target_dummy_01_005 = true,
		chill_wick_target_dummy_01_006 = true,
		chill_wick_target_dummy_01_007 = true,
		chill_wick_target_dummy_01_008 = true,
		chill_wick_target_dummy_01_009 = true,
		chill_wick_target_dummy_01_010 = true,
		chill_wick_target_dummy_01_011 = true,
		chill_wick_target_dummy_01_012 = true,
		chill_wick_target_dummy_01_013 = true,
		chill_wick_target_dummy_01_014 = true,
		chill_wick_target_dummy_01_015 = true,
		chill_wick_target_dummy_01_016 = true,
		chill_wolf_01_001 = true,
		max_001 = true,
		obj_link_002 = true,
		obj_link_003 = true,
	}

	function MissionManager:_add_script(data)
		local instances = data.instances
		for i = #instances, 1, -1 do
			if _G.Celer.delete_instances[instances[i]] then
				table.remove(instances, i)
			end
		end

		cel_original_missionmanager_addscript(self, data)
	end

end
