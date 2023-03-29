local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_playerstandard_init = PlayerStandard.init
function PlayerStandard:init(...)
	kpr_original_playerstandard_init(self, ...)
	table.insert(self._input, HoldButtonMetaInput:new('kpr_delayed_interact_secondary', 'interact_secondary', nil, 0.5))
end

local kpr_original_playerstandard_checkactioninteract = PlayerStandard._check_action_interact
function PlayerStandard:_check_action_interact(t, input)
	if input.btn_interact_release then
		self.kpr_delayed_interact_press_t = nil
	end
	if self.kpr_delayed_interact_press_t and t - self.kpr_delayed_interact_press_t > 0.5 then
		self.kpr_delayed_interact_press_t = nil
		if Keepers.settings.hold_primary_interaction_emulates_secondary_interaction then
			input.btn_interact_secondary_press = true
		end
	end

	local new_action = kpr_original_playerstandard_checkactioninteract(self, t, input)

	if input.btn_interact_press then
		self.kpr_delayed_interact_press_t = not new_action and self._start_intimidate and t or nil
	end

	if not new_action and input.btn_kpr_delayed_interact_secondary_press and not self:_action_interact_forbidden() then
		self.kpr_delayed_interact_secondary_press = true
		if managers.groupai:state():whisper_mode() then
			if Keepers.settings.delayed_awakening_input then
				self.kpr_can_awaken_bot = true
				self:_start_action_intimidate(t, true)
				self._start_intimidate = false
				self.kpr_can_awaken_bot = false
			end
		else
			self:_start_action_intimidate(t, true)
			self._start_intimidate = false
		end
		self.kpr_delayed_interact_secondary_press = false
	end

	return new_action
end

local unit_type_teammate = 2
local unit_type_minion = 22

local kpr_original_playerstandard_getinteractiontarget = PlayerStandard._get_interaction_target
function PlayerStandard:_get_interaction_target(char_table, my_head_pos, cam_fwd)
	if Keepers.enabled then
		if not self.kpr_secondary and Keepers.settings.filter_shout_at_teamai and not Keepers:is_filter_key_pressed() then
			for i = #char_table, 1, -1 do
				local slot = char_table[i].unit:slot()
				if slot == 16 or slot == 24 then
					table.remove(char_table, i)
				end
			end
		else
			if self.kpr_add_ai_teammates_cool and Network:is_server() then
				for _, u_data in pairs(managers.groupai:state():all_AI_criminals()) do
					if alive(u_data.unit) then
						self:_add_unit_to_char_table(char_table, u_data.unit, unit_type_teammate, 100000, true, true, 0.01, my_head_pos, cam_fwd)
					end
				end
			end

			if self.add_minions_to_teammates then
				local peer_id = managers.network:session():local_peer():id()
				for key, unit in pairs(managers.groupai:state():all_converted_enemies()) do
					if alive(unit) and unit:base().kpr_minion_owner_peer_id == peer_id and not unit:character_damage():dead() then
						self:_add_unit_to_char_table(char_table, unit, unit_type_minion, 100000, true, true, 0.01, my_head_pos, cam_fwd)
					end
				end
			end
		end
	end

	return kpr_original_playerstandard_getinteractiontarget(self, char_table, my_head_pos, cam_fwd)
end

local kpr_original_playerstandard_getintimidationaction = PlayerStandard._get_intimidation_action
function PlayerStandard:_get_intimidation_action(prime_target, char_table, amount, primary_only, detect_only, secondary)
	if not Keepers.enabled then
		-- qued
	elseif detect_only then
		-- qued
	elseif prime_target and prime_target.unit:in_slot(16, 24) then
		local is_ok, is_teammate_ai, is_my_minion
		local my_peer_id = managers.network:session():local_peer():id()
		local unit = prime_target.unit

		local record = managers.groupai:state():all_criminals()[unit:key()]
		if record and record.ai then
			is_teammate_ai = true
			local cdmg = unit:character_damage()
			is_ok = not cdmg:arrested() and not cdmg:need_revive()
		else
			is_my_minion = unit:base().kpr_minion_owner_peer_id == my_peer_id
			is_ok = is_my_minion
		end

		if is_ok then
			local awaken = unit:base().kpr_awaken
			if awaken ~= 2 and managers.groupai:state():whisper_mode() then
				if not Keepers.settings.delayed_awakening_input or self.kpr_can_awaken_bot then
					if secondary and is_teammate_ai then
						if awaken == 1 or not Keepers.casing_ok then
							unit:base().kpr_awaken = 2
							unit:movement():_switch_to_not_cool(true)
						elseif not awaken then
							unit:base().kpr_awaken = 1
						end
						Keepers:send_state(unit, Keepers:get_lua_networking_text(my_peer_id, unit, 1), false)
						return 'come', false, prime_target
					end
				end
				if not awaken then
					return
				end
			end

			local kpr_mode = Keepers.settings[secondary and 'secondary_mode' or 'primary_mode']
			if self.kpr_delayed_interact_secondary_press then
				local modes = { true, true, true, true }
				modes[Keepers.settings.primary_mode] = false
				modes[Keepers.settings.secondary_mode] = false
				for i = #modes, 1, -1 do
					if modes[i] then
						kpr_mode = i
						break
					end
				end
			end

			local t = TimerManager:game():time()
			local player_need_revive = self._unit:character_damage():need_revive()
			local wp_position = managers.hud and managers.hud:gcw_get_my_custom_waypoint()

			if player_need_revive or kpr_mode == 1
				or (not secondary and Keepers.settings.filter_only_stop_calls and not Keepers:is_filter_key_pressed())
				or (unit:base().kpr_is_keeper and not wp_position)
				or (is_teammate_ai and unit:base().kpr_following_peer_id ~= my_peer_id and not wp_position)
			then
				Keepers:send_state(unit, Keepers:get_lua_networking_text(my_peer_id, unit, 1), false)
				if is_my_minion and not player_need_revive then
					self._intimidate_t = t - 0.5
					return 'come', false, prime_target
				end

			else
				self._intimidate_t = t - 0.5
				if is_teammate_ai then
					DelayedCalls:Add('DelayedModKPR_bot_ok_' .. unit:id(), 1.5, function()
						if alive(unit) then
							unit:sound():say('r03x_sin')
						end
					end)
				end
				Keepers:send_state(unit, Keepers:get_lua_networking_text(my_peer_id, unit, kpr_mode), true)
				Keepers:show_covers(unit)
				if wp_position then
					self:say_line('f40_any', managers.groupai:state():whisper_mode())
					if not self:_is_using_bipod() then
						self:_play_distance_interact_redirect(t, 'cmd_gogo')
					end
					return 'kpr_boost', false, prime_target -- will do nothing
				else
					return 'ai_stay', false, prime_target
				end
			end

			secondary = false
		end
	end

	return kpr_original_playerstandard_getintimidationaction(self, prime_target, char_table, amount, primary_only, detect_only, secondary)
end

local kpr_original_playerstandard_getunitintimidationaction = PlayerStandard._get_unit_intimidation_action
function PlayerStandard:_get_unit_intimidation_action(intimidate_enemies, intimidate_civilians, intimidate_teammates, only_special_enemies, intimidate_escorts, intimidation_amount, primary_only, detect_only, secondary)
	if Keepers.enabled then
		self.kpr_secondary = secondary
		self.add_minions_to_teammates = intimidate_teammates and Keepers:can_call_jokers(self._ext_movement:current_state_name())
		self.kpr_add_ai_teammates_cool = intimidate_teammates and managers.groupai:state():whisper_mode()
	end

	return kpr_original_playerstandard_getunitintimidationaction(self, intimidate_enemies, intimidate_civilians, intimidate_teammates, only_special_enemies, intimidate_escorts, intimidation_amount, primary_only, detect_only, secondary)
end
