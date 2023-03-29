local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

local ids_cob = Idstring('co_box')
local ids_cc = Idstring('contour_color')
function _OcclusionManager:remove_occlusion(unit)
	if alive(unit) then
		local objects = unit:get_objects_by_type(self._model_ids)
		for _, obj in ipairs(objects) do
			if obj:name() == ids_cob or obj:cast_shadows() then
				obj:set_skip_occlusion(true)
			else
				for _, m in ipairs(obj:materials()) do
					if m:variable_exists(ids_cc) then
						obj:set_skip_occlusion(true)
						break
					end
				end
			end
		end
	end

	self._skip_occlusion[unit:key()] = true
end
