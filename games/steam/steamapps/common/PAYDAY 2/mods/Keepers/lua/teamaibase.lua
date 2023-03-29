local key = ModPath .. '	' .. RequiredScript
if _G[key] then return else _G[key] = true end

if not TeamAIBase.upgrade_value then
	TeamAIBase.upgrade_value = function() end
end
