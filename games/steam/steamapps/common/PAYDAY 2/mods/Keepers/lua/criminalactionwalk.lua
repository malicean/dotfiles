local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

function CriminalActionWalk:_get_max_walk_speed()
	local speed = CriminalActionWalk.super._get_max_walk_speed(self)

	local carry_id = self._ext_movement:carry_id()
	if carry_id then
		speed = deep_clone(speed)
		local speed_modifier = Keepers:patch_carry_speed(tweak_data.carry.types[tweak_data.carry[carry_id].type].move_speed_modifier)
		for k, v in pairs(speed) do
			speed[k] = v * speed_modifier
		end
	end

	return speed
end

function CriminalActionWalk:_get_current_max_walk_speed(move_dir)
	local speed = CriminalActionWalk.super._get_current_max_walk_speed(self, move_dir)

	local carry_id = self._ext_movement:carry_id()
	if carry_id then
		local tdc = tweak_data.carry
		local speed_modifier = Keepers:patch_carry_speed(tdc.types[tdc[carry_id].type].move_speed_modifier)
		speed = speed * speed_modifier
	end

	return speed
end
