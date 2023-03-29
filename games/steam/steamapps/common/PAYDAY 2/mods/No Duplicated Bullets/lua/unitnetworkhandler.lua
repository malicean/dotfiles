local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

function UnitNetworkHandler:action_aim_state(cop, state, sender_rpc)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(cop) or not self._verify_sender(sender_rpc) then
		return
	end

	local mov = cop:movement()
	if not mov then
		return
	end

	if state then
		local shoot_action = {
			block_type = 'action',
			body_part = 3,
			type = 'shoot'
		}
		mov:action_request(shoot_action)
	else
		mov:sync_action_aim_end()
	end
end
