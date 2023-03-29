local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

function CopLogicIdle.queued_update(data)
	local my_data = data.internal_data
	local delay = data.logic._upd_enemy_detection(data)
	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)
		return
	end

	local objective = data.objective

	if objective and data.kpr_keep_position and data.is_converted then
		if Keepers:can_change_state(data.unit) then
			if data.kpr_mode == 2 then
				if not data.kpr_stand_t and data.unit:anim_data().crouch then
					data.kpr_stand_t = data.t + math.random(2, 4)
				end
				if data.kpr_stand_t and data.t > data.kpr_stand_t then
					if CopLogicAttack._chk_request_action_stand(data) then
						data.kpr_stand_t = nil
					end
				end
			elseif data.kpr_mode == 3 and mvector3.distance(data.kpr_keep_position, data.unit:movement():m_pos()) > 50 then
				objective.in_place = nil
				CopLogicBase._exit(data.unit, 'travel')
				return
			elseif data.kpr_mode == 4 then
				if not my_data.kpr_wait_cover_t then
					my_data.kpr_wait_cover_t = data.t
				elseif data.t - my_data.kpr_wait_cover_t > 1 then
					local area = managers.groupai:state():get_area_from_nav_seg_id(managers.navigation:get_nav_seg_from_pos(data.kpr_keep_position))
					local cover = managers.navigation:find_cover_in_nav_seg_1(area.nav_segs)
					local gotopos = cover and cover[1] or managers.navigation:find_random_position_in_segment(data.unit:movement():nav_tracker():nav_segment())
					if gotopos then
						objective.in_place = nil
						data.kpr_keep_position = mvector3.copy(gotopos)
						data.unit:base().kpr_keep_position = data.kpr_keep_position
						CopLogicBase._exit(data.unit, 'travel')
					end
					return
				end
			end
		end
	end

	if my_data.has_old_action then
		CopLogicIdle._upd_stop_old_action(data, my_data, objective)
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.important and true)
		return
	end

	if data.is_converted and (not objective or objective.type == 'free') and (not data.path_fail_t or data.t - data.path_fail_t > 1) then
		managers.groupai:state():on_criminal_jobless(data.unit)
		if my_data ~= data.internal_data then
			return
		end
	end

	if CopLogicIdle._chk_exit_non_walkable_area(data) then
		return
	end
	if CopLogicIdle._chk_relocate(data) then
		return
	end

	CopLogicIdle._perform_objective_action(data, my_data, objective)
	CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)
	if data.cool then
		CopLogicIdle.upd_suspicion_decay(data)
	end
	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)
		return
	end

	if data.important then
		delay = 0.1
	else
		delay = delay or 0.3
	end
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay, data.important and true)
end

function CopLogicIdle.clbk_action_timeout(ignore_this, data)
	local my_data = data.internal_data
	CopLogicBase.on_delayed_clbk(my_data, my_data.action_timeout_clbk_id)
	my_data.action_timeout_clbk_id = nil

	local old_objective = data.objective
	if not old_objective then
		return
	end

	my_data.action_expired = true
	local anim_data = data.unit:anim_data()
	if anim_data.act and anim_data.needs_idle then
		CopLogicIdle._start_idle_action_from_act(data)
	end

	if not old_objective.kpr_done then
		data.objective_complete_clbk(data.unit, old_objective)
	end
end
