local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_teamaibrain_onlongdisinteracted = TeamAIBrain.on_long_dis_interacted
function TeamAIBrain:on_long_dis_interacted(amount, other_unit, secondary)
	local peer_id = managers.network:session():peer_by_unit(other_unit):id()
	if not Keepers:is_modded_client(peer_id) then
		Keepers:send_state(self._unit, Keepers:get_lua_networking_text(peer_id, self._unit, secondary and 2 or 1), secondary)
	end

	secondary = false
	return kpr_original_teamaibrain_onlongdisinteracted(self, amount, other_unit, secondary)
end

local kpr_original_teamaibrain_oncoolstatechanged = TeamAIBrain.on_cool_state_changed
function TeamAIBrain:on_cool_state_changed(state)
	kpr_original_teamaibrain_oncoolstatechanged(self, state)

	if not state and self._attention_handler then
		if managers.groupai:state():whisper_mode() then
			PlayerMovement.set_attention_settings(self, {
					'pl_mask_on_foe_non_combatant_whisper_mode_stand',
					'pl_mask_on_foe_combatant_whisper_mode_stand'
				}, 'team_AI')
		end
	end
end

function TeamAIBrain:search_for_path(search_id, to_pos, prio, access_neg, nav_segs)
	if not access_neg and self._unit:base().kpr_awaken == 1 then
		access_neg = managers.navigation:convert_access_flag('teamAI1')
	end

	return TeamAIBrain.super.search_for_path(self, search_id, to_pos, prio, access_neg, nav_segs)
end

function TeamAIBrain:search_for_path_from_pos(search_id, from_pos, to_pos, prio, access_neg, nav_segs)
	if not access_neg and self._unit:base().kpr_awaken == 1 then
		access_neg = managers.navigation:convert_access_flag('teamAI1')
	end

	return TeamAIBrain.super.search_for_path_from_pos(self, search_id, from_pos, to_pos, prio, access_neg, nav_segs)
end

function TeamAIBrain:search_for_coarse_path(search_id, to_seg, verify_clbk, access_neg)
	if not access_neg and self._unit:base().kpr_awaken == 1 then
		access_neg = 'teamAI1'
	end

	return TeamAIBrain.super.search_for_coarse_path(self, search_id, to_seg, verify_clbk, access_neg)
end
