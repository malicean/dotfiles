local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

FadingContour:UpdateHvtContourColors()

ContourExt.fc_last_ratio = 1

local fc_original_contourext_add = ContourExt.add
function ContourExt:add(typ, sync, multiplier, ...)
	if self._contour_list then
		for _, setup in ipairs(self._contour_list) do
			if setup.type == typ then
				self:apply_to_linked('add', typ, sync, multiplier)
				break
			end
		end
	end

	local result = fc_original_contourext_add(self, typ, sync, multiplier, ...)

	if result and result.fadeout_t then
		result.fc_start_t = TimerManager:game():time()
	end

	return result
end

local fc_original_contourext_update = ContourExt.update
function ContourExt:update(unit, t, dt)
	fc_original_contourext_update(self, unit, t, dt)

	local contour_list = self._contour_list
	local contour = contour_list and contour_list[1]
	if contour and not contour.flash_t then
		local fadeout_t = contour.fadeout_t
		if fadeout_t and t < fadeout_t then
			if self._unit:id() == -1 then
				fadeout_t = fadeout_t - 8 * dt
				contour.fadeout_t = fadeout_t
			end

			local fade_duration = fadeout_t - contour.fc_start_t
			local ratio = math.min(1, FadingContour:FadeModifier(fadeout_t, t, fade_duration))
			local ratio_changed = math.abs(self.fc_last_ratio - ratio) > 0.01
			if ratio_changed or self._types[contour.type].color_dmg then
				self:fade_color(ratio, contour)
			end
		end
	end
end

local idstr_material = Idstring('material')
local idstr_contour_color = Idstring('contour_color')
local color = Vector3()
local mvec3_dis = mvector3.distance
local mvec3_mul = mvector3.multiply
local mvec3_set = mvector3.set
function ContourExt:fade_color(ratio, contour)
	contour = contour or self._contour_list and self._contour_list[1]
	if not contour then
		return
	end

	local ctype = self._types[contour.type]
	local base_color = ctype.color or contour.color

	if ctype.damage_bonus_distance and ctype.color_dmg and self._unit:slot() ~= 25 then
		local player = managers.player:player_unit()
		if alive(player) then
			local threshold = tweak_data.upgrades.values.player.marked_inc_dmg_distance[ctype.damage_bonus_distance][1]
			local dis = mvec3_dis(player:position(), self._unit:position())
			if dis > threshold then
				base_color = ctype.color_dmg
			end
		end
	end

	mvec3_set(color, base_color)
	mvec3_mul(color, ratio)

	-- don't trust what's cached, might be outdated and fade won't occur
	local materials = self._unit:get_objects_by_type(idstr_material)
	self._materials = materials
	for _, material in ipairs(materials) do
		if alive(material) and material:variable_exists(idstr_contour_color) then
			material:set_variable(idstr_contour_color, color)
		end
	end
end
