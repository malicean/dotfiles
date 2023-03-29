local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Network:is_client() then
	return
end

local kpr_original_teamaimovement_setcool = TeamAIMovement.set_cool
function TeamAIMovement:set_cool(state)
	if not state then
		if managers.groupai:state():whisper_mode() then
			if self._ext_base.kpr_awaken == 1 then
				return
			end
		end
	end

	return kpr_original_teamaimovement_setcool(self, state)
end

local kpr_original_teamaimovement_switchtonotcool = TeamAIMovement._switch_to_not_cool
function TeamAIMovement:_switch_to_not_cool(...)
	local restore_original_heat_listener_clbk
	local original_heat_listener_clbk = self._heat_listener_clbk
	if managers.groupai:state():whisper_mode() then
		self._heat_listener_clbk = nil
		restore_original_heat_listener_clbk = true
	else
		self._ext_base.kpr_awaken = 2
	end

	kpr_original_teamaimovement_switchtonotcool(self, ...)

	if restore_original_heat_listener_clbk then
		self._heat_listener_clbk = original_heat_listener_clbk
	end
end

local kpr_original_teamaimovement_heatclbk = TeamAIMovement.heat_clbk
function TeamAIMovement:heat_clbk(...)
	if self._ext_base.kpr_awaken == 2 and self._ext_brain.on_cool_state_changed then
		self._ext_brain:on_cool_state_changed(false)
	end

	kpr_original_teamaimovement_heatclbk(self, ...)
end

function TeamAIMovement:chk_action_forbidden(action_type)
	if action_type == 'stand' and self._ext_base.kpr_mode == 2 and self._ext_anim.reload then
		return true -- screw _upd_pose()
	end
	return TeamAIMovement.super.chk_action_forbidden(self, action_type)
end
