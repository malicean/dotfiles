local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_copactionreload_playreload = CopActionReload._play_reload
function CopActionReload:_play_reload()
	local result = kpr_original_copactionreload_playreload(self)
	if result and self._ext_base and self._ext_base.kpr_mode == 2 and not self._ext_anim.crouch then
		local res = self._ext_movement:action_request({ body_part = 4, type = 'crouch', blocks = { stand = -1} })
		if res then
			self.kpr_crouched_for_reload = true
		end
	end
	return result
end
