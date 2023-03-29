local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local radius = 15
local m_obj_pos = Vector3()

function ObjectInteractionManager:kpr_fat_raycheck_ok(unit, camera_pos, locator, ignore_unit)
	if locator then
		local obstructed = World:raycast('ray', locator:position(), camera_pos,
			'ignore_unit', ignore_unit,
			'sphere_cast_radius', radius,
			'ray_type', 'bag body',
			'slot_mask', self._slotmask_interaction_obstruction,
			'report')
		if not obstructed then
			return 2, 0
		end
		obstructed = World:raycast('ray', locator:position(), camera_pos,
			'ignore_unit', ignore_unit,
			'ray_type', 'bag body',
			'slot_mask', self._slotmask_interaction_obstruction,
			'report')
		if not obstructed then
			return 1, 0
		end

	else
		local check_objects = unit:interaction():ray_objects()
		if check_objects then
			for _, object in ipairs(check_objects) do
				object:m_position(m_obj_pos)
				local obstructed = unit:raycast('ray', m_obj_pos, camera_pos,
					'ignore_unit', ignore_unit,
					'sphere_cast_radius', radius,
					'ray_type', 'bag body',
					'slot_mask', self._slotmask_interaction_obstruction,
					'report')
				if not obstructed then
					return 2, 0
				end
				obstructed = unit:raycast('ray', m_obj_pos, camera_pos,
					'ignore_unit', ignore_unit,
					'ray_type', 'bag body',
					'slot_mask', self._slotmask_interaction_obstruction,
					'report')
				if not obstructed then
					return 1, 0
				end
			end

		else
			local obstructed = unit:raycast('ray', unit:interaction():interact_position(), camera_pos,
				'ignore_unit', ignore_unit,
				'sphere_cast_radius', radius,
				'ray_type', 'bag body',
				'slot_mask', self._slotmask_interaction_obstruction,
				'report')
			if not obstructed then
				return 2, 0
			end
			obstructed = unit:raycast('ray', camera_pos, unit:interaction():interact_position(),
				'ignore_unit', ignore_unit,
				'ray_type', 'bag body',
				'slot_mask', self._slotmask_interaction_obstruction
				) -- not a report
			if not obstructed then
				return 1, 0
			else
				return 0, obstructed.distance
			end
		end
	end

	return 0, 1
end

local function _check_destructible_unit(col_ray)
	if not col_ray or not col_ray.unit:damage() then
		return false
	end

	local body_dmg = col_ray.body:extension() and col_ray.body:extension().damage
	return body_dmg
		and (not body_dmg._body_element or body_dmg._body_element._damage_multiplier > 0)
		and body_dmg._endurance and body_dmg._endurance.melee
end

function ObjectInteractionManager:kpr_get_destructible_obstacle(unit, camera_pos, locator)
	if locator then
		local ray = World:raycast('ray', locator:position(), camera_pos,
			'ray_type', 'bag body',
			'slot_mask', self._slotmask_interaction_obstruction)
		if _check_destructible_unit(ray) then
			return ray
		end
	else
		local check_objects = unit:interaction():ray_objects()
		if check_objects then
			for _, object in ipairs(check_objects) do
				object:m_position(m_obj_pos)
				local ray = unit:raycast('ray', m_obj_pos, camera_pos,
					'ray_type', 'bag body',
					'slot_mask', self._slotmask_interaction_obstruction)
				if _check_destructible_unit(ray) then
					return ray
				end
			end
		else
			local ray = unit:raycast('ray', unit:interaction():interact_position(), camera_pos,
				'ray_type', 'bag body',
				'slot_mask', self._slotmask_interaction_obstruction)
			if _check_destructible_unit(ray) then
				return ray
			end
		end
	end

	return false
end
