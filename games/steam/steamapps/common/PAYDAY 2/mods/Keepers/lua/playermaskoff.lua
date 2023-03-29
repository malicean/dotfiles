local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if Network:is_client() then
	return
end

local kpr_original_playermaskoff_enter = PlayerMaskOff.enter
function PlayerMaskOff:enter(...)
	Keepers.casing_ok = not managers.groupai:state():enemy_weapons_hot()
	return kpr_original_playermaskoff_enter(self, ...)
end
