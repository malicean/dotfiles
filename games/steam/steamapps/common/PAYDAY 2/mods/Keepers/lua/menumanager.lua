local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

dofile(ModPath .. 'lua/_hud_icons.lua')
dofile(ModPath .. 'lua/_smu_notif.lua')

local mvec3_add = mvector3.add
local mvec3_cpy = mvector3.copy
local mvec3_dir = mvector3.direction
local mvec3_dis = mvector3.distance
local mvec3_dot = mvector3.dot
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_z = mvector3.z
local tmp_vec = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()

function json.safe_decode(data)
	local status, result = pcall(json.decode, data)
	return result
end

_G.Keepers = _G.Keepers or {}
Keepers.path = ModPath
Keepers.data_path = SavePath .. 'keepers.txt'
Keepers.enabled = false
Keepers.clients = {}
Keepers.joker_names = {}
Keepers.joker_name_max_length = 25
Keepers.radial_health = {}
Keepers.wp_to_unit_id = {}
Keepers.unitid_to_SO = {}
Keepers.rescuers = {}
Keepers.interaction_no_dot_value = -0.02
Keepers.interaction_grace_period = 0.05
Keepers.settings = {
	primary_mode = 3,
	secondary_mode = 4,
	keybind_mode = 3,
	hold_primary_interaction_emulates_secondary_interaction = false,
	filter_shout_at_teamai = false,
	filter_shout_at_teamai_key = 'left shift',
	filter_only_stop_calls = false,
	show_joker_health = true,
	show_my_joker_name = true,
	send_my_joker_name = true,
	show_other_jokers_names = true,
	my_joker_name = 'My Joker',
	jokers_run_like_teamais = true,
	interaction_timer_multiplier = 1,
	delayed_awakening_input = true,
	teamais_can_interact = true,
	faster_but_weaker_while_carrying = true,
}
Keepers.icons = {
	mode_1 = nil,
	mode_2 = 'kpr_stationary',
	mode_3 = 'pd2_defend',
	mode_4 = 'kpr_patrol',
	assist = 'kpr_assist',
	revive = 'wp_revive',
	hunt = 'pd2_kill',
}

function Keepers:can_call_jokers(current_state_name)
	return current_state_name == 'standard' or current_state_name == 'carry'
end

function Keepers:can_search_for_cover(unit)
	local kpr_mode = alive(unit) and unit:base().kpr_mode
	return kpr_mode and kpr_mode > 2
end

function Keepers:is_filter_key_pressed()
	local key = self.settings.filter_shout_at_teamai_key
	if key:find('mouse ') then
		return Input:mouse():down(Idstring(key:sub(7)))
	else
		return Input:keyboard():down(Idstring(key))
	end
end

function Keepers:apply_filter_mode()
	local v = self.settings.filter_mode
	if v == 1 then
		self.settings.filter_shout_at_teamai = false
		self.settings.filter_only_stop_calls = false
	elseif v == 2 then
		self.settings.filter_shout_at_teamai = false
		self.settings.filter_only_stop_calls = true
	elseif v == 3 then
		self.settings.filter_shout_at_teamai = true
		self.settings.filter_only_stop_calls = false
	end
end

function Keepers:load_settings()
	local file = io.open(self.data_path, 'r')
	if file then
		for k, v in pairs(json.safe_decode(file:read('*all')) or {}) do
			self.settings[k] = v
		end
		file:close()
	end
	self:apply_filter_mode()
	self:save_settings()

	for i = 1, 4 do
		self.joker_names[i] = ''
	end

	local peer_id = managers.network and managers.network:session() and managers.network:session():local_peer():id() or 1
	self.joker_names[peer_id] = self.settings.show_my_joker_name and self.settings.my_joker_name or ''
end

function Keepers:save_settings()
	local file = io.open(self.data_path, 'w+')
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function Keepers:get_joker_name_by_peer(peer_id)
	local name = self.joker_names[peer_id]
	if managers.network:session():local_peer():id() == peer_id then
		return name
	elseif not self.settings.show_other_jokers_names then
		return ''
	elseif name == 'My Joker' or name == '' then
		local peer = managers.network:session():peer(peer_id)
		if peer then
			name = tostring(peer:name()) .. "'s joker"
		end
	end
	return name
end

function Keepers:set_joker_label(unit)
	local panel_id = unit:unit_data().name_label_id
	if not panel_id then
		local label_data = { unit = unit, name = self:get_joker_name_by_peer(unit:base().kpr_minion_owner_peer_id) }
		panel_id = managers.hud:_add_name_label(label_data)
		unit:unit_data().name_label_id = panel_id
	end

	local name_label = managers.hud:_get_name_label(panel_id)
	if not name_label then
		return
	end

	local previous_icon = name_label.panel:child('bag')
	if previous_icon then
		name_label.panel:remove(previous_icon)
		previous_icon = nil
	end

	local radial_health = name_label.panel:bitmap({
		name = 'bag',
		texture = 'guis/textures/pd2/hud_health',
		render_template = 'VertexColorTexturedRadial',
		blend_mode = 'add',
		alpha = 1,
		w = 16,
		h = 16,
		layer = 0,
	})
	name_label.bag = radial_health
	local txt = name_label.panel:child('text')
	radial_health:set_center_y(txt:center_y())
	local l, r, w, h = txt:text_rect()
	radial_health:set_left(txt:left() + w + 2)
	radial_health:set_visible(self.settings.show_joker_health)

	self.radial_health[unit:id()] = radial_health
end

function Keepers:is_modded_client(peer_id)
	return not not self.clients[peer_id]
end

function Keepers:get_goonmod_waypoint_position(peer_id)
	local pos = managers.hud and managers.hud:gcw_get_custom_waypoint_by_peer(peer_id)
	if not pos then
		return nil
	end

	local tracker = managers.navigation:create_nav_tracker(pos, false)
	local tracker_pos = tracker:field_position()
	managers.navigation:destroy_nav_tracker(tracker)

	mvec3_set(tmp_vec, pos)
	mvec3_set(tmp_vec2, tracker_pos)
	mvec3_set_z(tmp_vec, 0)
	mvec3_set_z(tmp_vec2, 0)
	if mvec3_dis(tmp_vec, tmp_vec2) < 100 then
		pos = tracker_pos
	end

	mvec3_set(tmp_vec, pos)
	mvec3_set(tmp_vec2, tmp_vec)
	mvec3_set_z(tmp_vec, tmp_vec.z + 10)
	mvec3_set_z(tmp_vec2, tmp_vec.z - 2000)
	local ground_slotmask = managers.slot:get_mask('AI_graph_obstacle_check')
	local ray = World:raycast('ray', tmp_vec, tmp_vec2, 'slot_mask', ground_slotmask, 'ray_type', 'walk')
	return ray and ray.hit_position
end

function Keepers:get_lua_networking_text(peer_id, unit, mode)
	local data = {}
	data.unit_id = unit:id()
	data.peer_id = peer_id or unit:base().kpr_minion_owner_peer_id or unit:base().kpr_following_peer_id
	data.charname = managers.criminals:character_name_by_unit(unit) or 'jokered_cop'
	data.mode = mode
	return json.encode(data)
end

function Keepers:get_minions_by_peer(peer_id)
	local result = {}

	for key, unit in pairs(managers.groupai:state():all_converted_enemies()) do
		if alive(unit) and unit:base().kpr_minion_owner_peer_id == peer_id and not unit:character_damage():dead() then
			table.insert(result, unit)
		end
	end

	return result
end

function Keepers:get_teamAIs_owned_by_peer(peer_id)
	local result = {}

	for _, record in pairs(managers.groupai:state():all_AI_criminals()) do
		local u = record.unit
		if alive(u) and u:base().kpr_following_peer_id == peer_id then
			table.insert(result, u)
		end
	end

	return result
end

function Keepers:get_stopped_AI_criminals(peer_id)
	local result = {}

	for _, record in pairs(managers.groupai:state():all_AI_criminals()) do
		local u = record.unit
		if alive(u) and u:base().kpr_is_keeper then
			if not peer_id or u:base().kpr_following_peer_id == peer_id then
				table.insert(result, u)
			end
		end
	end

	return result
end

function Keepers:get_revive_assistants(player_unit)
	local result = {}

	local pos = player_unit:position()
	local peer = managers.network:session():peer_by_unit(player_unit)
	for _, list in ipairs({self:get_stopped_AI_criminals(), peer and self:get_minions_by_peer(peer:id()) or {}}) do
		for _, unit in pairs(list) do
			if unit:base().kpr_keep_position then
				local pos2 = unit:position()
				if math.abs(pos.z - pos2.z) < 200 and mvec3_dis(pos, pos2) < 2000 then
					table.insert(result, unit)
				end
			end
		end
	end

	return result
end

function Keepers:dismiss_revive_assistants(rescued_unit)
	if type(rescued_unit) == 'userdata' then
		local restore_special_mode_list = self.rescuers[rescued_unit:key()]
		if restore_special_mode_list then
			self.rescuers[rescued_unit:key()] = nil
			for unit, params in pairs(restore_special_mode_list) do
				if self:can_change_state(unit) then
					self:set_state(self:get_lua_networking_text(params.following_peer_id, unit, params.mode), true, params.keep_position)
				end
			end
		end
	end
end

function Keepers:get_regen_ratio(unit)
	if self.settings.faster_but_weaker_while_carrying then
		local carry_id = unit:movement():carry_id()
		if carry_id and tweak_data.carry.types[tweak_data.carry[carry_id].type].move_speed_modifier < 1 then
			return 0.05
		end
	end

	local objective = unit:brain():objective()
	if objective then
		local objective_type = objective.type
		if objective_type == 'revive' or objective_type == 'follow' then
			-- qued
		elseif objective_type == 'defend_area' or objective_type == 'stop' then
			-- qued
		elseif objective_type == 'act' and objective.mkp_route then
			-- qued
		else
			return 0.05
		end
	end

	return 0.1
end

function Keepers:patch_carry_speed(speed_modifier)
	if speed_modifier < 1 and self.settings.teamais_can_interact and self.settings.faster_but_weaker_while_carrying then
		speed_modifier = 1 - (1 - speed_modifier) * 0.5
	end
	return speed_modifier
end

function Keepers:get_special_mode_values(unit)
	local u_base = unit:base()
	return {
		following_peer_id = u_base.kpr_following_peer_id,
		mode = u_base.kpr_mode,
		keep_position = mvector3.copy(u_base.kpr_keep_position)
	}
end

function Keepers:make_restore_keeper_state_objective(bot_unit, mode, pos)
	local ub = bot_unit:base()
	return {
		type = 'restore_keeper_state',
		kpr_mode = mode or ub.kpr_mode,
		kpr_keep_position = pos or ub.kpr_keep_position,
		kpr_following_peer_id = ub.kpr_following_peer_id,
	}
end

function Keepers:get_stay_objective(unit, drop_carry, icon_override)
	local ub = unit:base()
	local kpr_mode = ub.kpr_mode
	local keep_position = ub.kpr_keep_position or unit:position()
	if kpr_mode == 3 or kpr_mode == 4 then
		return {
			type = 'defend_area',
			kpr_drop_carry = drop_carry,
			kpr_icon = icon_override or self.icons['mode_' .. kpr_mode],
			kpr_objective = true,
			kpr_pos = mvec3_cpy(keep_position),
			kpr_mode = kpr_mode,
			nav_seg = managers.navigation:get_nav_seg_from_pos(keep_position, true),
			attitude = 'avoid',
			stance = 'hos',
			scan = true
		}
	else
		return {
			type = 'stop',
			kpr_drop_carry = drop_carry,
			kpr_icon = icon_override or self.icons['mode_' .. kpr_mode],
			kpr_objective = true,
			kpr_pos = mvec3_cpy(keep_position),
			kpr_mode = kpr_mode,
			nav_seg = managers.navigation:get_nav_seg_from_pos(keep_position, true),
			pos = mvec3_cpy(keep_position)
		}
	end
end

local brush = Draw:brush(Color(100, 106, 187, 255) / 255, 2)
function Keepers:show_covers(unit)
	local covers = {}
	local kpr_mode = unit:base().kpr_mode

	local keep_position = unit:base().kpr_keep_position
	if not keep_position then
		return
	end

	if kpr_mode == 3 then
		local i = 1
		for _, cover_pos in ipairs(self._covers) do
			if mvec3_dis(keep_position, cover_pos) < 400 then
				local delta_z = keep_position.z - cover_pos.z
				if delta_z > -100 and delta_z < 100 then
					covers[i] = mvec3_cpy(cover_pos)
					i = i + 1
				end
			end
		end

	elseif kpr_mode == 4 then
		local nav_seg = managers.navigation:get_nav_seg_from_pos(keep_position)
		local i = 1
		for _, cover_pos in ipairs(self._covers) do
			if managers.navigation:get_nav_seg_from_pos(cover_pos) == nav_seg then
				covers[i] = mvec3_cpy(cover_pos)
				i = i + 1
			end
		end
	end

	for _, cover in pairs(covers) do
		mvec3_set_z(cover, cover.z - 3)
		tmp_vec = mvec3_cpy(cover)
		mvec3_set_z(tmp_vec, tmp_vec.z + 20)
		brush:cone(tmp_vec, cover, 30)
	end
end

function Keepers:send_state(unit, unit_text_ref, is_keeper, forced_position)
	local changed = self:set_state(unit_text_ref, is_keeper, forced_position)
	if Network:is_client() then
		LuaNetworking:SendToPeer(1, 'Keeper' .. (is_keeper and 'ON' or 'OFF'), unit_text_ref)
	elseif changed then
		if not Global.game_settings.single_player then
			LuaNetworking:SendToPeers('Keeper' .. (is_keeper and 'ON' or 'OFF'), unit_text_ref)
		end
		if managers.groupai:state()._ai_criminals[unit:key()] then
			for peer_id, peer in pairs(managers.network:session():peers()) do
				if not self:is_modded_client(peer_id) then
					peer:send_queued_sync('sync_team_ai_stopped', unit, is_keeper)
				end
			end
		end
	end
end

function Keepers:recv_state(sender, unit_text_ref, is_keeper)
	if self:set_state(unit_text_ref, is_keeper) then
		if Network:is_server() and not Global.game_settings.single_player then
			LuaNetworking:SendToPeers('Keeper' .. (is_keeper and 'ON' or 'OFF'), unit_text_ref)
		end
	end
end

function Keepers:can_change_state(unit)
	if not alive(unit) then
		return false
	end

	local ucd = unit:character_damage()
	if not ucd or ucd.need_revive and ucd:need_revive() or ucd.arrested and ucd:arrested() or ucd.dead and ucd:dead() then
		return false
	end

	local uad = unit:anim_data()
	if uad and uad.acting then
		return false
	end

	local brain = unit:brain()
	if brain then
		local objective = brain.objective and brain:objective()
		if objective and objective.forced then
			if managers.groupai:state():whisper_mode() and not unit:base().kpr_awaken then
				return false
			end
		end
	end

	return true
end

function Keepers:get_unit(data)
	local is_converted = data.charname == 'jokered_cop'
	if is_converted then
		for _, minion_unit in pairs(self:get_minions_by_peer(data.peer_id)) do
			if minion_unit:id() == data.unit_id then
				return minion_unit
			end
		end
	else
		return managers.criminals and managers.criminals:character_unit_by_name(data.charname)
	end
	return false
end

function Keepers:is_position_ok(pos, threshold)
	if not pos then
		return false
	end

	local result = true
	local closest_navseg = managers.navigation:get_nav_seg_from_pos(pos, false)
	local navseg = managers.navigation:get_nav_seg_from_pos(pos, true)

	if navseg ~= closest_navseg then
		local tracker = managers.navigation:create_nav_tracker(pos, false)
		local tracker_pos = tracker:field_position()
		managers.navigation:destroy_nav_tracker(tracker)
		if mvec3_dis(pos, tracker_pos) > (threshold or 150) then
			result = false
		end
	end

	return result, closest_navseg, navseg
end

function Keepers:set_state(unit_text_ref, is_keeper, forced_position, icon_override)
	local data = json.safe_decode(unit_text_ref)
	local peer_id = data.peer_id

	local unit = self:get_unit(data)
	if not self:can_change_state(unit) then
		return false
	end

	local u_base = unit:base()
	if data.charname == 'jokered_cop' then
		if unit:character_damage():dead() and unit:unit_data().name_label_id then
			self:destroy_label(unit)
		end
	else
		u_base.kpr_following_peer_id = peer_id
	end

	if Network:is_client() then
		u_base.kpr_is_keeper = is_keeper
		u_base.kpr_mode = tonumber(data.mode)
		return
	end

	local previous_keep_position = u_base.kpr_keep_position

	local u_movement = unit:movement()
	local u_brain = u_movement._ext_brain
	local objective = u_brain:objective()
	if objective and objective.type == 'revive' then
		local peer_to_revive = managers.network:session():peer_by_unit(objective.follow_unit)
		if peer_to_revive and peer_to_revive:id() == peer_id then
			if not unit:anim_data().crouch then
				return
			end
		end
	end

	local new_objective
	local previous_kpr_mode = u_base.kpr_mode
	local previous_kpr_is_keeper = u_base.kpr_is_keeper
	if is_keeper then
		local kpr_mode = tonumber(data.mode)
		local can_check_so = true
		if forced_position then
			can_check_so = false
		elseif u_base.kpr_awaken ~= 2 and managers.groupai:state():whisper_mode() then
			can_check_so = false
			local is_spotter = CrewAbilitySpotter and managers.player:has_category_upgrade('team', CrewAbilitySpotter.ability_name)
			icon_override = is_spotter and 'kpr_look' or 'ai_stopped'
		end
		local secondary = kpr_mode == self.settings.secondary_mode
		local so = can_check_so and self:get_special_objective_from_waypoint(unit, peer_id, secondary)
		if so then
			so.kpr_ordered_by_peer_id = peer_id
			u_base.kpr_is_keeper = false
			u_base.kpr_mode = 1
			u_base.kpr_keep_position = nil

			if so ~= u_brain:objective() then
				new_objective = so
			end
			if u_brain._logic_data and u_brain._logic_data.internal_data and u_brain._logic_data.internal_data.shooting then
				-- qued
			else
				u_movement:set_attention(nil)
			end
		else
			local wp_pos = forced_position or self:get_goonmod_waypoint_position(peer_id)
			local wp_is_ok = self:is_position_ok(wp_pos)
			local dest_pos = wp_is_ok and wp_pos or u_movement:get_walk_to_pos() or u_movement:nav_tracker():field_position()

			u_base.kpr_keep_position = nil
			if managers.groupai:state():kpr_count_teammates_near_pos(dest_pos) > 0 then
				dest_pos = u_brain:kpr_get_position_around(dest_pos, 400)
			end

			u_base.kpr_is_keeper = true
			u_base.kpr_mode = kpr_mode
			u_base.kpr_keep_position = mvec3_cpy(dest_pos)
			local drop_carry = not forced_position and wp_is_ok
			new_objective = self:get_stay_objective(unit, drop_carry, icon_override)
		end

	else
		u_base.kpr_is_keeper = false
		u_base.kpr_mode = 1
		u_base.kpr_keep_position = nil
		if not previous_kpr_is_keeper and not u_base.kpr_awaken and u_movement:cool() then
			-- qued
		else
			local peer = managers.network:session():peer(peer_id)
			local peer_unit = peer and peer:unit()
			if peer_unit then
				new_objective = {
					kpr_icon = nil,
					type = 'follow',
					follow_unit = peer_unit,
					scan = true,
					nav_seg = peer_unit:movement():nav_tracker():nav_segment(),
					called = true,
					pos = peer_unit:movement():nav_tracker():field_position(),
				}
			end
		end
	end

	if u_brain._logic_data then
		u_brain._logic_data.kpr_is_keeper = u_base.kpr_is_keeper
		u_brain._logic_data.kpr_mode = u_base.kpr_mode
		u_brain._logic_data.kpr_keep_position = u_base.kpr_keep_position
	end

	if new_objective then
		u_brain:set_objective(new_objective)
	end

	if previous_keep_position ~= u_base.kpr_keep_position then
		local walk_action = u_movement:_get_latest_walk_action()
		if not walk_action then
			-- qued
		elseif walk_action._nav_link then
			if walk_action._simplified_path then
				walk_action._simplified_path = {
					walk_action._simplified_path[1],
					mvec3_cpy(walk_action._nav_link.element._values.search_position)
				}
			end
		else
			walk_action:stop()
			walk_action._expired = true
		end
	end

	local current_mode = u_base.kpr_mode or 1
	local changed = previous_kpr_mode ~= current_mode or previous_kpr_is_keeper ~= u_base.kpr_is_keeper
	return changed
end

function Keepers:reset_label(unit, is_converted, icon, ext_data)
	if is_converted then
		if unit:character_damage():dead() then
			if unit:unit_data().name_label_id then
				self:destroy_label(unit)
			end
			return
		end

		if not unit:unit_data().name_label_id then
			self:set_joker_label(unit)
		end
	end

	local name_label = managers.hud:_get_name_label(unit:unit_data().name_label_id)
	if not name_label then
		return
	end

	local previous_icon = name_label.panel:child('infamy')
	if previous_icon then
		name_label.panel:remove(previous_icon)
	end

	if icon then
		local icon_color
		if icon == self.icons.revive then
			icon_color = ext_data == managers.network:session():local_peer():id() and Color.red or Color.white
		end
		local color = icon_color or tweak_data.chat_colors[managers.criminals:character_color_id_by_unit(unit)]
		local texture, rect = tweak_data.hud_icons:get_icon_data(icon)
		local bmp = name_label.panel:bitmap({
			blend_mode = 'add',
			name = 'infamy',
			texture = texture,
			texture_rect = rect,
			layer = 0,
			color = color:with_alpha(0.9),
			w = 16,
			h = 16,
			visible = true,
		})
		name_label.infamy = bmp
		local txt = name_label.panel:child('text')
		bmp:set_center_y(txt:center_y())
		bmp:set_right(txt:left())
	end

	if icon ~= nil and Network:is_server() and not Global.game_settings.single_player then
		LuaNetworking:SendToPeers('KeepersICON', self:get_lua_networking_text(ext_data, unit, icon))
	end
	unit:base().kpr_icon = icon
end

function Keepers:set_icon(sender, unit_text_ref)
	local data = json.safe_decode(unit_text_ref)
	if not data then
		return
	end

	local unit = self:get_unit(data)
	if alive(unit) then
		self:reset_label(unit, data.charname == 'jokered_cop', data.mode, data.peer_id)
	end
end

function Keepers:destroy_label(unit)
	if alive(unit) then
		managers.hud:_remove_name_label(unit:unit_data().name_label_id)
		unit:base().kpr_is_keeper = nil
		unit:base().kpr_keep_position = nil
		unit:unit_data().name_label_id = nil
		if unit:base().kpr_minion_owner_peer_id then
			self.radial_health[unit:id()] = nil
			unit:base().kpr_minion_owner_peer_id = nil
		end
	end
end

function Keepers:process_message(sender, messageType, data)
	if messageType == 'Keepers?' then
		if data then
			self.joker_names[sender] = data:sub(1, self.joker_name_max_length)
		end
		self.clients[sender] = true
		LuaNetworking:SendToPeer(sender, 'Keepers!', self.settings.send_my_joker_name and self.settings.my_joker_name or '')

	elseif messageType == 'Keepers!' then
		if sender == 1 then
			self.enabled = true
		end
		if data and self.settings.show_other_jokers_names and data ~= '' then
			self.joker_names[sender] = data:sub(1, self.joker_name_max_length)
		end

	elseif not self.enabled then
		-- qued

	elseif messageType == 'KeeperON' then
		self:recv_state(sender, data, true)

	elseif messageType == 'KeeperOFF' then
		self:recv_state(sender, data, false)

	elseif messageType == 'KeepersICON' then
		if Network:is_client() then
			self:set_icon(sender, data)
		end
	end
end

Hooks:Add('NetworkReceivedData', 'NetworkReceivedData_KPR', function(sender, messageType, data)
	Keepers:process_message(sender, messageType, data)
end)

Hooks:Add('BaseNetworkSessionOnLoadComplete', 'BaseNetworkSessionOnLoadComplete_KPR', function(local_peer, id)
	Keepers:load_settings()
	if id == 1 then
		Keepers.enabled = true
		Keepers.clients[1] = true
	else
		LuaNetworking:SendToPeers('Keepers?', Keepers.settings.send_my_joker_name and Keepers.settings.my_joker_name or '')
	end
end)

Hooks:Add('LocalizationManagerPostInit', 'LocalizationManagerPostInit_KPR', function(loc)
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
		for _, filename in pairs(file.GetFiles(Keepers.path .. 'loc/')) do
			local str = filename:match('^(.*).txt$')
			if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
				language_filename = filename
				break
			end
		end
	end

	if language_filename then
		loc:load_localization_file(Keepers.path .. 'loc/' .. language_filename)
	end
	loc:load_localization_file(Keepers.path .. 'loc/english.txt', false)
end)

Hooks:Add('MenuManagerInitialize', 'MenuManagerInitialize_KPR', function(menu_manager)
	function MenuCallbackHandler:KeepersMenuCheckboxClbk(item)
		Keepers.settings[item:name()] = item:value() == 'on'
	end

	local function _update_faster_weaker_item(value)
		local menu = MenuHelper:GetMenu('kpr_options_menu')
		local faster_weaker = menu:item('faster_but_weaker_while_carrying')
		faster_weaker:set_enabled(value)
		if not value then
			faster_weaker:set_value('off')
			Keepers.settings.faster_but_weaker_while_carrying = false
		end
	end

	function MenuCallbackHandler:KeepersMenuCheckboxInteractionsClbk(item)
		local value = item:value() == 'on'
		_update_faster_weaker_item(value)
		Keepers.settings[item:name()] = value
	end

	function MenuCallbackHandler:KeepersMenuNumericValue(item)
		Keepers.settings[item:name()] = tonumber(item:value())
	end

	function MenuCallbackHandler:KeepersMenuValue(item)
		Keepers.settings[item:name()] = item:value()
	end

	function MenuCallbackHandler:KeepersFilterMode(item)
		Keepers.settings.filter_mode = tonumber(item:value())
		Keepers:apply_filter_mode()
	end

	function MenuCallbackHandler:KeepersSave(item)
		Keepers:save_settings()
	end

	function MenuCallbackHandler:KeybindFollow(item)
		if Keepers.enabled then
			Keepers:change_state(false)
		end
	end

	function MenuCallbackHandler:KeybindStay(item)
		if Keepers.enabled then
			Keepers:change_state(true)
		end
	end

	function MenuCallbackHandler.KeepersChangedFocus(node, focus)
		if focus then
			local menu = MenuHelper:GetMenu('kpr_options_menu')
			local menu_item = menu and menu:item('teamais_can_interact')
			if menu_item then
				if Network:is_server() and game_state_machine:verify_game_state(GameStateFilters.any_ingame_playing) then
					menu_item:set_enabled(false)
				end
				_update_faster_weaker_item(menu_item:value() == 'on')
			end
		end
	end

	Keepers:load_settings()
	MenuHelper:LoadFromJsonFile(Keepers.path .. 'menu/options.txt', Keepers, Keepers.settings)
end)

function Keepers:change_state(new_state)
	if not (managers.network and managers.network:session() and Utils:IsInHeist()) then
		return
	end

	local peer_id = managers.network:session():local_peer():id()
	local refs = {}
	local kpr_mode = new_state and self.settings.keybind_mode or 1

	for _, unit in pairs(self:get_minions_by_peer(peer_id)) do
		refs[unit] = self:get_lua_networking_text(peer_id, unit, kpr_mode)
	end

	for _, unit in pairs(new_state and self:get_teamAIs_owned_by_peer(peer_id) or self:get_stopped_AI_criminals(peer_id)) do
		refs[unit] = self:get_lua_networking_text(peer_id, unit, kpr_mode)
	end

	for unit, unit_text_ref in pairs(refs) do
		if not unit:base().kpr_is_keeper == new_state then
			self:send_state(unit, unit_text_ref, new_state)
		end
	end
end

function Keepers:is_upgrade_forbidden_to_criminal_AI(requires_upgrade)
	local typ = type(requires_upgrade)
	if typ == 'table' then
		local key = tostring(requires_upgrade.category) .. '_' .. tostring(requires_upgrade.upgrade)
		return not table.contains(tweak_data.skilltree.default_upgrades, key)
	elseif typ == 'string' then
		return not table.contains(tweak_data.skilltree.default_upgrades, requires_upgrade)
	end
end

function Keepers:get_covered_interactable_units(refresh)
	if not self.covered_interactable_units or refresh then
		self.covered_interactable_units = {}

		for _, scripts in pairs(managers.mission._scripts) do
			if scripts._element_groups and scripts._element_groups.ElementUnitSequenceTrigger then
				for _, trigger in ipairs(scripts._element_groups.ElementUnitSequenceTrigger) do
					if trigger._values.enabled then
						for _, exec in ipairs(trigger._values.on_executed) do
							local elm = managers.mission:get_element_by_id(exec.id)
							if elm and elm._values.enabled and elm._values.trigger_list then
								for _, item in ipairs(elm._values.trigger_list) do
									if item.notify_unit_sequence == 'enable_interaction' then
										local int_unit = managers.worlddefinition:get_unit(item.notify_unit_id)
										local cd = alive(int_unit) and int_unit:carry_data()
										if cd then
											self.covered_interactable_units[int_unit:key()] = int_unit
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	return self.covered_interactable_units
end

function Keepers:is_interactable_unit_assigned(interactive_unit, instigator)
	if not alive(instigator) then
		return false
	end

	local instigator_key = instigator:key()
	local interactive_unit_key = interactive_unit:key()
	for ukey, record in pairs(managers.groupai:state()._ai_criminals) do
		local unit = record.unit
		if unit:key() ~= instigator_key then
			local objective = unit:brain():objective()
			while objective do
				if alive(objective.interactive_unit) and objective.interactive_unit:key() == interactive_unit_key then
					return true
				end
				objective = objective.followup_objective
			end
		end
	end

	return false
end

function Keepers:is_unit_interactable(unit, instigator)
	if not alive(unit) then
		return false
	end

	local forbidden_interactions = {
		ammo_bag = true,
		c4_bag = true,
		c4_bag_dynamic = true,
		corpse_dispose = true,
		drill_upgrade = true,
		first_aid_kit = true,
		hold_take_parachute = true,
		open_from_inside = true,
		player_zipline = true,
	}
	if CrewAbilityPockets then
		forbidden_interactions[CrewAbilityPockets.interaction_name] = true
	end

	local slot = unit:slot()
	if (slot == 1 or slot == 14) and self.settings.teamais_can_interact 
		or slot == 3 or slot == 16 or slot == 17
		or slot == 22 and not CopDamage.is_civilian(unit:base()._tweak_table)
	then
		local interaction = unit:interaction()
		if not interaction
			or interaction._special_equipment
			or forbidden_interactions[interaction.tweak_data]
			or interaction.tweak_data:match('^access_camera') and not managers.groupai:state():whisper_mode()
		then
			-- qued
		elseif interaction:active() and not interaction:disabled()
			or self.covered_interactable_units and self.covered_interactable_units[unit:key()]
		then
			local td = interaction._tweak_data
			if not td
				or td.special_equipment
				or td.equipment_consume
				or td.special_equipment_block
				or td.required_deployable
				or td.deployable_consume
				or td.contour == 'deployable'
				or self:is_upgrade_forbidden_to_criminal_AI(td.requires_upgrade)
			then
				-- qued
			elseif not self:is_interactable_unit_assigned(unit, instigator) then
				return true
			end
		end
	end

	return false
end

function Keepers:get_horizontal_distance_from_graph(pos)
	local tracker = managers.navigation:create_nav_tracker(pos, false)
	local tracker_pos = tracker:field_position()
	managers.navigation:destroy_nav_tracker(tracker)
	mvec3_set_z(tracker_pos, mvec3_z(pos))
	return mvec3_dis(tracker_pos, pos)
end

function Keepers:get_yaw(interactive_unit, interact_pos)
	mvec3_set(tmp_vec, interact_pos)
	mvec3_set_z(tmp_vec, 0)
	mvec3_set(tmp_vec2, interactive_unit:interaction():interact_position())
	mvec3_set_z(tmp_vec2, 0)
	mvec3_dir(tmp_vec, tmp_vec, tmp_vec2)
	return Rotation(tmp_vec, math.UP):yaw()
end

function Keepers:find_interaction_position(interactive_unit, delta_yaw)
	local slot_mask = managers.slot:get_mask('AI_graph_obstacle_check')
	local i_pos = interactive_unit:interaction():interact_position()
	local i_pos_z = mvec3_z(i_pos)
	mvec3_set(tmp_vec, i_pos)

	if delta_yaw then
		local fwd = Rotation(((interactive_unit:rotation():yaw() + delta_yaw + 180) % 360) - 180, 0, 0):y()
		mvec3_mul(fwd, 80)
		mvec3_add(tmp_vec, fwd)
	end

	local z = mvec3_z(tmp_vec)
	mvec3_set_z(tmp_vec, z + 20)
	mvec3_set(tmp_vec2, tmp_vec)
	mvec3_set_z(tmp_vec2, z - 10000)
	local col_ray = World:raycast('ray', tmp_vec, tmp_vec2, 'slot_mask', slot_mask)
	if col_ray then
		mvec3_set(tmp_vec, col_ray.position)
	end

	local tracker = managers.navigation:create_nav_tracker(tmp_vec, false)
	local tracker_pos = tracker:field_position()
	local navseg = tracker:nav_segment()
	managers.navigation:destroy_nav_tracker(tracker)

	local tracker_z = mvec3_z(tracker_pos) - 25
	if i_pos_z - tracker_z < -10 then
		mvec3_set_z(tmp_vec, z - 100)
		local col_ray = World:raycast('ray', tmp_vec, tmp_vec2, 'slot_mask', slot_mask)
		if col_ray then
			mvec3_set(tmp_vec, col_ray.position)
		end
	end

	return mvec3_cpy(tmp_vec), i_pos_z - mvec3_z(tmp_vec), navseg
end

function Keepers:get_interactive_unit_dot(unit, camera_pos)
	local interact_axis = unit:interaction():interact_axis()
	if not interact_axis then
		return self.interaction_no_dot_value
	end

	mvec3_set(tmp_vec3, unit:interaction():interact_position())
	mvec3_sub(tmp_vec3, camera_pos)
	mvec3_norm(tmp_vec3)
	return mvec3_dot(tmp_vec3, interact_axis)
end

function Keepers.is_crappy_pos(pos) -- remember scarface painting
	local pos1 = mvec3_cpy(pos) + Vector3(0, 0, 50)

	local tracker = managers.navigation:create_nav_tracker(pos1, false)
	local pos2 = tracker:field_position() + Vector3(0, 0, 50)
	managers.navigation:destroy_nav_tracker(tracker)

	return World:raycast('ray', pos1, pos2, 'slot_mask', managers.interaction._slotmask_interaction_obstruction, 'report')
end

function Keepers:calc_distance_to_interaction_possibilities(possibilities, bot_unit)
	if not possibilities[1] or not alive(bot_unit) then
		return
	end

	local multiseg = false
	local navseg = possibilities[1].navseg
	for i = #possibilities, 1, -1 do
		if possibilities[i].navseg ~= navseg then
			multiseg = true
			break
		end
	end

	if multiseg then
		local start_i_seg = bot_unit:movement():nav_tracker():nav_segment()
		local search_data = {
			bypass_congestion = true,
			start_i_seg = start_i_seg,
			seg_searched = {},
			discovered_seg = {[start_i_seg] = true},
			seg_to_search = {{i_seg = start_i_seg}},
			access_pos = bot_unit:brain()._SO_access
		}

		for i = #possibilities, 1, -1 do
			local possibility = possibilities[i]
			if start_i_seg == possibility.navseg then
				possibility.dis = 0
			else
				search_data.end_i_seg = possibility.navseg
				search_data.to_pos = possibility.ground_pos

				local path = managers.navigation:_execute_coarce_search(search_data)
				if path then
					possibility.dis = path.coarse_dis
				else
					table.remove(possibilities, i)
				end
			end
		end
	end
end

local guessed_head_pos = Vector3()
function Keepers:get_interaction_position_around(interactive_unit, bot_unit)
	local possibilities = {}
	local yaw = interactive_unit:rotation():yaw()

	local interaction = interactive_unit:interaction()
	local i_pos = interaction:interact_position()
	local i_pos_z = mvec3_z(i_pos)
	for delta_yaw = 0, 270, 90 do
		local possibility = {
			delta_yaw = delta_yaw,
			dis = 10000000000
		}

		possibility.ground_pos, possibility.height, possibility.navseg = self:find_interaction_position(interactive_unit, possibility.delta_yaw)
		if math.within(possibility.height, -20, 300) then
			mvec3_set(guessed_head_pos, possibility.ground_pos)
			local pgz = mvec3_z(guessed_head_pos)
			local h = math.clamp(i_pos_z - pgz + 50, 115, 180)
			mvec3_set_z(guessed_head_pos, pgz + h)

			possibility.dot = self:get_interactive_unit_dot(interactive_unit, guessed_head_pos)
			if possibility.dot < -0.01 then
				local blocker_ray = managers.interaction:kpr_get_destructible_obstacle(interactive_unit, guessed_head_pos)
				possibility.ray, possibility.col_dis = managers.interaction:kpr_fat_raycheck_ok(interactive_unit, guessed_head_pos, nil, blocker_ray and blocker_ray.unit)

				mvec3_set(tmp_vec, i_pos)
				local dir = Rotation(((yaw + delta_yaw + 180) % 360) - 180, 0, 0):y()
				mvec3_mul(dir, 100)
				mvec3_add(tmp_vec, dir)
				possibility.gap = self:get_horizontal_distance_from_graph(tmp_vec)

				if possibility.gap == 0 or not self.is_crappy_pos(possibility.ground_pos) then
					if possibility.ray > 0
					or possibility.dot < self.interaction_no_dot_value
					or possibility.col_dis / mvec3_dis(guessed_head_pos, i_pos) > 0.8 -- TODO: redo
					then
						possibility.blocker_ray = blocker_ray
						table.insert(possibilities, possibility)
					end
				end
			end
		end
	end

	self:calc_distance_to_interaction_possibilities(possibilities, bot_unit)

	table.sort(possibilities, function (a, b)
		if a.ray ~= b.ray then return a.ray > b.ray end
		if a.dis ~= b.dis then return a.dis < b.dis end
		if a.dot ~= b.dot then return a.dot < b.dot end
		if a.gap ~= b.gap then return a.gap < b.gap end
		if math.abs(a.height - b.height) > 5 then
			return a.height > b.height
		end
		if a.col_dis ~= b.col_dis then return a.col_dis > b.col_dis end
		return a.delta_yaw < b.delta_yaw
	end)

	local best = possibilities[1]
	if not best then
		return false, nil
	end

	return best.ground_pos, best.blocker_ray
end

function Keepers:get_interaction_animation(interaction, height, action_duration)
	local interaction_name = interaction.tweak_data
	local computer_interactions = {
		big_computer_hackable = 35,
		big_computer_server = 35,
		hold_search_computer = 35,
		hack_suburbia_outline = false,
		security_station_keyboard = false,
	}

	if interaction_name == 'hold_signal_driver' then
		return 'e_so_low_kicks', nil, nil, -130

	elseif interaction_name:match('^access_camera') then
		return 'interact_enter', 'interact_exit'

	elseif height > 130 then
		if action_duration <= 3 then
			return 'e_so_tube_interact'
		else
			return 'interact_enter', 'interact_exit'
		end

	elseif height > 60 then
		if interaction_name == 'drill_jammed' then
			return 'e_so_low_lockpick_enter', 'e_so_low_lockpick_exit', true, 10
		elseif interaction._tweak_data.is_lockpicking then
			return 'e_so_low_lockpick_enter', 'e_so_low_lockpick_exit', true
		elseif computer_interactions[interaction_name] ~= nil then
			return 'e_so_keyboard_type_loop', nil, nil, computer_interactions[interaction_name]
		elseif action_duration <= 3 then
			return 'e_so_interact_mid'
		else
			return 'interact_enter', 'interact_exit'
		end

	elseif height < 5 then
		if action_duration <= 1 then
			return 'e_so_plant_c4_floor'
		end
	end

	return 'untie'
end

function Keepers:get_interaction_icon(interaction, icon)
	if interaction._tweak_data.is_lockpicking then
		return 'wp_key'
	end

	if interaction.tweak_data == 'corpse_alarm_pager' then
		return 'wp_talk'
	end

	if interaction.tweak_data:match('^access_camera') then
		return 'kpr_camera'
	end

	local td_icon = interaction._tweak_data.icon
	if td_icon and td_icon ~= 'develop' then
		return td_icon
	end

	return icon or 'pd2_generic_interact'
end

local function _get_revive_objective(bot_unit, target_unit_id)
	local gstate = managers.groupai:state()
	for so_id, so in pairs(gstate._special_objectives) do
		if so.unit_id == target_unit_id then
			local objective = gstate.clone_objective(so.data.objective)
			bot_unit:brain():set_objective(objective)
			if so.data.admin_clbk then
				so.data.admin_clbk(bot_unit)
			end
			managers.groupai:state():remove_special_objective(so_id)
			return objective
		end
	end
end

function Keepers:get_special_objective_from_waypoint(bot_unit, peer_id, secondary)
	if not CustomWaypoints or not managers.hud then
		return
	end

	local peer = managers.network:session():peer(peer_id)
	if not peer or not alive(peer:unit()) then
		return
	end

	local wp_position, wp_unit = managers.hud:gcw_get_custom_waypoint_by_peer(peer_id)

	return self:get_special_objective(bot_unit, secondary, wp_position, wp_unit)
end

local ids_gen_drill_small_upright = Idstring('units/pd2_dlc_pal/equipment/gen_interactable_drill_small_upright/gen_interactable_drill_small_upright')
local ids_gen_saw_no_jam = Idstring('units/pd2_dlc_glace/equipment/gen_interactable_saw_no_jam/gen_interactable_saw_no_jam')

function Keepers:get_special_objective(bot_unit, secondary, wp_position, retrieve_unit, interactive_unit)
	local bot_brain = alive(bot_unit) and bot_unit:brain()
	if bot_brain and bot_brain._logic_data and bot_brain._logic_data.is_converted then
		return
	end

	local wp_on_ground, unit_id, icon, obj_wp_id

	if interactive_unit then
		if not alive(interactive_unit) or not self:is_unit_interactable(interactive_unit, bot_unit) then
			return
		end

	elseif alive(retrieve_unit) then
		local new_objective = self:make_hunt_stolen_bag_objective(bot_unit, retrieve_unit, secondary)
		if new_objective then
			bot_unit:movement():throw_bag()
		end
		return new_objective

	elseif wp_position then
		obj_wp_id = CustomWaypoints:GetAssociatedObjectiveWaypoint(wp_position)
		if type(obj_wp_id) == 'number' then
			local wp_element = managers.mission:get_element_by_id(obj_wp_id)
			if not wp_element then
				return
			end
			unit_id = self.wp_to_unit_id[wp_element._values.instance_name or obj_wp_id]
			icon = wp_element._values.icon

		elseif type(obj_wp_id) == 'string' then
			local objective
			unit_id = obj_wp_id:match('^ReviveInteractionExt(.*)$')
			if unit_id then
				objective = _get_revive_objective(bot_unit, tonumber(unit_id))
			end
			return objective

		else
			local tracker = managers.navigation:create_nav_tracker(wp_position, true)
			wp_on_ground = math.within(mvec3_z(wp_position) + 22.5 - tracker:field_z(), -10, 20)
			managers.navigation:destroy_nav_tracker(tracker)
		end

		if unit_id then
			interactive_unit = managers.worlddefinition:get_unit(unit_id)
		end

	else
		return
	end

	if not self:is_unit_interactable(interactive_unit, bot_unit) then
		local best_unit
		local best_dis = 100000
		local carrying_bag = bot_unit and bot_unit:movement():carrying_bag()
		for _, int_unit in ipairs(managers.interaction._interactive_units) do
			if self:is_unit_interactable(int_unit) then
				local interaction = int_unit:interaction()
				local ipos = interaction:interact_position()
				local dis = mvec3_dis(wp_position, ipos)
				if wp_on_ground and dis > 75 then
					-- qued
				elseif dis < best_dis and dis < interaction:interact_distance() then
					if interaction._tweak_data
					and interaction._tweak_data.blocked_hint == 'carry_block'
					and (carrying_bag or dis >= 50 and int_unit:slot() == 14)
					then
						-- qued
					elseif not self:is_interactable_unit_assigned(int_unit, bot_unit) then
						best_unit = int_unit
						best_dis = dis
					end
				end
			end
		end

		if not best_unit then
			return
		end

		if secondary and Monkeepers and not carrying_bag then
			local cd = best_unit.carry_data and best_unit:carry_data()
			if cd then
				cd:mkp_register_putbackintoplace_SO()
				local obj = cd:mkp_assign_SO(bot_unit)
				if obj then
					return obj
				end
			end
		end

		unit_id = best_unit and best_unit:unit_data() and best_unit:unit_data().unit_id
		interactive_unit = best_unit

		if not self:is_unit_interactable(interactive_unit) then
			return
		end
	end

	local interaction = interactive_unit:interaction()
	if interaction.tweak_data == 'revive' then
		return _get_revive_objective(bot_unit, interactive_unit:id())
	end

	local action_duration = interaction._tweak_data.timer and interaction._tweak_data.timer * self.settings.interaction_timer_multiplier or 0.5
	local so_values, exit_animation, hidden_weapon

	local so_id = self.unitid_to_SO[unit_id]
	if so_id then
		local so = managers.mission:get_element_by_id(so_id)
		if not so then
			return
		end
		so_values = so._values

		local inappropriate_anim = {
			e_so_balloon = true,
		}
		if inappropriate_anim[so_values.so_action] then
			local height = so_values.position and (mvec3_z(interaction:interact_position()) - mvec3_z(so_values.position)) or 75
			so_values.so_action, exit_animation, hidden_weapon, repos = self:get_interaction_animation(interaction, height, action_duration)
			icon = self:get_interaction_icon(interaction, icon)
		end
	end

	local destructible_blocker_ray
	if not so_values or not so_values.position then
		so_values = {}
		icon = self:get_interaction_icon(interaction, icon)

		local pos, repos
		local ub = interactive_unit:base()
		if ub and ub._sabotage_align_obj_name and (math.within(interactive_unit:rotation():pitch(), -10, 10) and interactive_unit:name() ~= ids_gen_drill_small_upright or interactive_unit:name() == ids_gen_saw_no_jam) then
			local align_obj = interactive_unit:get_object(Idstring(ub._sabotage_align_obj_name))
			pos = mvec3_cpy(align_obj:position())
			mvec3_set_z(pos, mvec3_z(interaction:interact_position())) -- align_obj may be seriously underground crap, cf WH's hack devices
			mvec3_set(tmp_vec, pos)
			mvec3_set_z(tmp_vec, mvec3_z(pos) - 300)
			local col_ray = World:raycast('ray', pos, tmp_vec, 'slot_mask', managers.slot:get_mask('AI_graph_obstacle_check'))
			if col_ray then
				pos = col_ray.position
			else
				mvec3_set_z(pos, mvec3_z(pos) - 25)
			end
		else
			pos, destructible_blocker_ray = self:get_interaction_position_around(interactive_unit, bot_unit)
			if not pos then
				if interaction.tweak_data:sub(-10, -1) == 'carry_drop' then
					pos = interaction:interact_position()
				else
					return
				end
			end
		end

		local height = mvec3_z(interaction:interact_position()) - mvec3_z(pos)
		so_values.so_action, exit_animation, hidden_weapon, repos = self:get_interaction_animation(interaction, height, action_duration)
		so_values.rotation = self:get_yaw(interactive_unit, pos)

		if repos then
			mvec3_set(tmp_vec, interaction:interact_position())
			mvec3_set_z(tmp_vec, mvec3_z(pos))
			mvec3_dir(tmp_vec, pos, tmp_vec)
			mvec3_mul(tmp_vec, repos)
			mvec3_add(pos, tmp_vec)
		end
		so_values.position = pos
	end

	local pos_ok, closest_navseg = self:is_position_ok(so_values.position)
	if not pos_ok then
		return
	end

	local new_objective = {
		bot_unit = bot_unit,
		interactive_unit = interactive_unit,
		interaction_name = interaction.tweak_data,
		duration = action_duration,
		exit_animation = exit_animation,
		hidden_weapon = hidden_weapon,

		kpr_important_location = not not (obj_wp_id or CustomWaypoints:GetAssociatedObjectiveWaypoint(so_values.position, 200)),
		kpr_icon = icon,
		destroy_clbk_key = false,
		type = 'act',
		pose = 'stand',
		interrupt_health = 0.4,
		interrupt_dis = 0,
		nav_seg = closest_navseg,
		pos = so_values.position,
		rot = so_values.rotation and Rotation(so_values.rotation, 0, 0),
		action = {
			kpr_so_expiration = true,
			variant = so_values.so_action,
			align_sync = true,
			body_part = 1,
			type = 'act',
			blocks = {
				act = -1,
				action = -1,
				aim = -1,
				heavy_hurt = -1,
				hurt = -1,
				light_hurt = -1,
				shoot = -1,
				turn = -1,
				walk = -1
			}
		},
		action_duration = action_duration
	}

	local old_objective = bot_brain and bot_brain:objective()
	if old_objective then
		if old_objective.kpr_pos then
			new_objective.followup_objective = self:make_restore_keeper_state_objective(bot_unit, old_objective.kpr_mode, old_objective.kpr_pos)
		else
			new_objective.followup_objective = old_objective
		end
	end

	new_objective.action_start_clbk = callback(self, self, 'on_action_started_SO', new_objective)
	new_objective.complete_clbk = callback(self, self, 'on_completed_SO', new_objective)
	new_objective.fail_clbk = callback(self, self, 'on_failed_SO', new_objective)

	if destructible_blocker_ray then
		return self:coat_objective_with_melee(new_objective, destructible_blocker_ray)
	else
		return new_objective
	end
end

function Keepers:coat_objective_with_melee(followup_objective, col_ray)
	local melee_objective = {
		followup_objective = followup_objective,

		kpr_icon = followup_objective.kpr_icon,
		destroy_clbk_key = false,
		type = 'act',
		pose = 'stand',
		interrupt_health = 0.4,
		interrupt_dis = 0,
		nav_seg = followup_objective.nav_seg,
		pos = followup_objective.pos,
		rot = followup_objective.rot,
		action_duration = 0.5,
		action = {
			kpr_so_expiration = true,
			variant = 'e_so_weapon_butt',
			align_sync = true,
			body_part = 1,
			type = 'act',
			blocks = {
				act = -1,
				action = -1,
				aim = -1,
				heavy_hurt = -1,
				hurt = -1,
				light_hurt = -1,
				shoot = -1,
				turn = -1,
				walk = -1
			}
		},

		kpr_colray_body = col_ray.body,

		complete_clbk = function(actor)
			followup_objective.bot_unit = actor
			if col_ray.body:enabled() then
				local damage = 1000
				col_ray.body:extension().damage:damage_melee(actor, col_ray.normal, col_ray.position, col_ray.ray, damage)
				managers.network:session():send_to_peers_synched('sync_body_damage_melee', col_ray.body, actor, col_ray.normal, col_ray.position, col_ray.ray, damage)
			end
		end
	}

	return melee_objective
end

function Keepers:on_action_started_SO(objective)
	local bot_name = alive(objective.bot_unit) and managers.criminals:character_name_by_unit(objective.bot_unit)
	if not bot_name then
		return
	end

	local interaction = alive(objective.interactive_unit) and objective.interactive_unit:interaction()
	if interaction and interaction:active() and not interaction:disabled() then
		-- qued
	else
		objective.bot_unit:brain():set_objective(objective.followup_objective)
		return
	end

	local status, timer = interaction:interact_start(objective.bot_unit)
	if status == false and not timer then
		objective.bot_unit:brain():set_objective(objective.followup_objective)
		return
	end

	local str = 'kpr;' .. bot_name .. ';' .. objective.interaction_name .. (objective.hidden_weapon and ';hw' or '')
	if managers.hud then
		managers.hud:kpr_teammate_progress(str, true, objective.duration, false)
	end

	local session = managers.network:session()
	for peer_id, peer in pairs(session:peers()) do
		if peer_id ~= 1 and self.clients[peer_id] then
			session:send_to_peer_synched(peer, 'sync_teammate_progress', 1, true, str, objective.duration, false)
		end
	end

	objective.kpr_action_started = true
end

function Keepers:finalize_SO(objective, success)
	local bot_name = alive(objective.bot_unit) and managers.criminals:character_name_by_unit(objective.bot_unit)
	if not bot_name then
		return
	end

	objective.bot_unit:movement():action_request({
		body_part = 1,
		type = 'act',
		variant = objective.exit_animation or 'idle',
	})

	if not objective.kpr_action_started then
		return
	end

	local str = 'kpr;' .. bot_name .. ';' .. objective.interaction_name .. (objective.hidden_weapon and ';hw' or '')
	if managers.hud then
		managers.hud:kpr_teammate_progress(str, false, objective.duration, success)
	end

	local session = managers.network:session()
	for peer_id, peer in pairs(session:peers()) do
		if peer_id ~= 1 and self.clients[peer_id] then
			session:send_to_peer_synched(peer, 'sync_teammate_progress', 1, false, str, objective.duration, success)
		end
	end
end

function Keepers:on_failed_SO(objective)
	if objective.kpr_action_started and alive(objective.interactive_unit) then
		local interaction = objective.interactive_unit:interaction()
		if interaction and interaction:active() and not interaction:disabled() then
			local bot_unit = objective.bot_unit
			interaction:interact_interupt(alive(bot_unit) and bot_unit)
			objective.interactive_unit = nil
		end
	end

	self:finalize_SO(objective, false)
end

function Keepers:on_completed_SO(objective)
	if objective.kpr_done then
		return
	end
	objective.kpr_done = true

	local bot_unit = objective.bot_unit
	local interactive_unit = objective.interactive_unit
	if interactive_unit and alive(bot_unit) then
		local interaction = alive(interactive_unit) and interactive_unit:interaction()
		if interaction and interaction:active() and not interaction:disabled() then
			interaction:interact(bot_unit)
			objective.interactive_unit = nil
		end

		local followup_objective = objective.followup_objective
		local wp_pos = objective.kpr_ordered_by_peer_id and managers.hud:gcw_get_custom_waypoint_by_peer(objective.kpr_ordered_by_peer_id)
		if not followup_objective or followup_objective.type == 'follow' then
			if wp_pos then
				self:send_state(bot_unit, self:get_lua_networking_text(objective.kpr_ordered_by_peer_id, bot_unit, 3), true)
			else
				self:send_state(bot_unit, self:get_lua_networking_text(objective.kpr_ordered_by_peer_id, bot_unit, 1), false)
			end
		elseif followup_objective.type == 'restore_keeper_state' then
			if wp_pos then
				-- followup_objective is already attributed
				self:send_state(bot_unit, self:get_lua_networking_text(objective.kpr_ordered_by_peer_id, bot_unit, 3), true)
			end
		end
	end

	self:finalize_SO(objective, true)
end

function Keepers:make_hunt_stolen_bag_objective(bot_unit, bag_unit, secondary)
	local thief_unit = alive(bag_unit) and bag_unit:carry_data():is_linked_to_unit()
	if not alive(thief_unit) then
		if secondary then
			return -- let Monkeepers handle the bag return
		else
			return self:get_special_objective(bot_unit, secondary, bag_unit:interaction():interact_position())
		end
	end
	if not thief_unit:in_slot(managers.slot:get_mask('enemies')) then
		return
	end

	local thief_pos = thief_unit:position()
	local pos_ok, thief_closest_navseg = self:is_position_ok(thief_pos)
	if not pos_ok then
		return
	end

	local clbk_data = {
		bot_unit = bot_unit,
		bag_unit = bag_unit,
		secondary = secondary
	}

	local new_objective = {
		kpr_reset_keeper_state = true,
		kpr_icon = self.icons.hunt,
		type = 'free',
		haste = 'run',
		pose = 'stand',
		interrupt_health = 0.4,
		interrupt_dis = 0,
		nav_seg = thief_closest_navseg,
		pos = thief_pos,
		complete_clbk = callback(self, self, 'on_completed_hunt_stolen_bag', clbk_data),
	}

	return new_objective
end

function Keepers:on_completed_hunt_stolen_bag(data)
	if not alive(data.bag_unit) then
		return
	end

	local new_objective = self:make_hunt_stolen_bag_objective(data.bot_unit, data.bag_unit, data.secondary)
	if new_objective or not Monkeepers or Monkeepers.disabled then
		-- thief is still running away, pursue!
		data.bot_unit:brain():set_objective(new_objective)
		return
	end

	local pos = data.bag_unit:position()
	for _, bag in ipairs(Monkeepers:get_bags_around(pos, 2000, false)) do
		bag:carry_data():mkp_register_putbackintoplace_SO()
	end

	data.bag_unit:carry_data():mkp_assign_SO(data.bot_unit)
end
