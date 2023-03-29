local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if not Network:is_server() then
	return
end

local kpr_original_copactionhurt_init = CopActionHurt.init
function CopActionHurt:init(action_desc, common_data)
	self.kpr_ext_base = common_data.ext_base
	self.original_kpr_keep_position = common_data.ext_base.kpr_keep_position
	return kpr_original_copactionhurt_init(self, action_desc, common_data)
end

local kpr_original_copactionhurt_onexit = CopActionHurt.on_exit
function CopActionHurt:on_exit()
	if self._expired and not self._died then
		local keep_position = self.kpr_ext_base.kpr_keep_position
		if keep_position and keep_position == self.original_kpr_keep_position then
			if self.kpr_ext_base.kpr_mode == 2 and Keepers:can_change_state(self._unit) then
				if mvector3.distance(self._ext_movement:nav_tracker():field_position(), keep_position) > 1 then
					local action_desc = {
						type = 'walk',
						variant = 'walk',
						body_part = 2,
						nav_path = { mvector3.copy(keep_position) },
						path_simplified = true,
						end_pose = 'stand',
						blocks = {
							walk = -1,
							turn = -1,
							act = -1,
							idle = -1
						}
					}
					self._ext_movement:action_request(action_desc)
				end
			end
		end
	end

	kpr_original_copactionhurt_onexit(self)
end
