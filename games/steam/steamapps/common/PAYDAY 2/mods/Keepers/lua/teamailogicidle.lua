local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local mvec3_cpy = mvector3.copy
local mvec3_dis = mvector3.distance

local kpr_original_teamailogicidle_enter = TeamAILogicIdle.enter
function TeamAILogicIdle.enter(data, new_logic_name, enter_params)
	local objective = data.objective
	if objective and objective.kpr_colray_body then
		if alive(objective.kpr_colray_body) and objective.kpr_colray_body:enabled() then
			-- qued
		else
			objective.action.variant = 'idle'
			objective.action_duration = 0
		end
	end

	kpr_original_teamailogicidle_enter(data, new_logic_name, enter_params)
end

local kpr_original_teamailogicidle_update = TeamAILogicIdle.update
function TeamAILogicIdle.update(data)
	if data.kpr_keep_position and data.objective and Keepers:can_change_state(data.unit) then
		if data.kpr_mode == 3 then
			if data.unit:character_damage():health_ratio() < 0.5 then
				-- qued
			elseif mvec3_dis(data.kpr_keep_position, data.m_pos) > 50 then
				TeamAILogicBase._exit(data.unit, 'travel')
				return
			end
		elseif data.kpr_mode == 4 then
			local my_data = data.internal_data
			if not my_data.kpr_wait_cover_t then
				my_data.kpr_wait_cover_t = data.t
			elseif data.t - my_data.kpr_wait_cover_t > 1 then
				local area = managers.groupai:state():get_area_from_nav_seg_id(managers.navigation:get_nav_seg_from_pos(data.kpr_keep_position))
				local cover = managers.navigation:find_cover_in_nav_seg_1(area.nav_segs)
				if cover then
					data.kpr_keep_position = mvec3_cpy(cover[1])
					data.unit:base().kpr_keep_position = data.kpr_keep_position
					TeamAILogicBase._exit(data.unit, 'travel')
				end
				return
			end
		end
	end

	kpr_original_teamailogicidle_update(data)
end

local kpr_original_teamailogicidle_actioncompleteclbk = TeamAILogicIdle.action_complete_clbk
function TeamAILogicIdle.action_complete_clbk(data, action)
	if action and action._action_desc and action._action_desc.kpr_so_expiration then
		action._expired = true
	end

	return kpr_original_teamailogicidle_actioncompleteclbk(data, action)
end
