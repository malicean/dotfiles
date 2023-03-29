local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Network and Network:is_server() then
	local kpr_original_copactionwarp_init = CopActionWarp.init
	function CopActionWarp:init(action_desc, common_data)
		local result = kpr_original_copactionwarp_init(self, action_desc, common_data)
		if result and common_data.ext_base.kpr_is_keeper then
			local gstate = managers.groupai:state()
			local u_key = self._unit:key()
			if gstate:all_AI_criminals()[u_key] or gstate:all_converted_enemies()[u_key] then
				Keepers:send_state(self._unit, Keepers:get_lua_networking_text(false, self._unit), false)
			end
		end
		return result
	end
end
