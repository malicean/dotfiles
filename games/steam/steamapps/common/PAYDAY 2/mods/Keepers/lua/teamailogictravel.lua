local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_teamailogictravel_enter = TeamAILogicTravel.enter
function TeamAILogicTravel.enter(data, new_logic_name, enter_params)
	kpr_original_teamailogictravel_enter(data, new_logic_name, enter_params)

	local my_data = data.internal_data
	CopLogicIdle._chk_has_old_action(data, my_data)

	if data.objective and data.objective.type ~= 'follow' and data.objective.pos then
		my_data.itr_direct_to_pos = data.objective.pos
	else
		my_data.itr_direct_to_pos = data.kpr_keep_position
	end
end
