local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local kpr_original_copactionshoot_update = CopActionShoot.update
function CopActionShoot:update(t)
	if self.kpr_crouched_for_reload and not self._ext_anim.reload then
		self.kpr_crouched_for_reload = nil
		if self._ext_anim.crouch then
			self._ext_movement:action_request({ body_part = 4, type = 'stand' })
		end
	end

	kpr_original_copactionshoot_update(self, t)
end
