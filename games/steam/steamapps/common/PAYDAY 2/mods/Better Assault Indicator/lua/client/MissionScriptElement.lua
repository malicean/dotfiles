local BAI = BAI
if BAI._hooks.MissionScriptElement then
    return
else
    BAI._hooks.MissionScriptElement = true
end

if Network:is_server() then
    return
end

if not (Global and Global.game_settings) then
    return
end

local level_id = Global.game_settings.level_id
local difficulty = Global.game_settings.difficulty
local first_assault_delay_t = 0
if level_id == "four_stores" then
end

if first_assault_delay_t ~= 0 then
    BAI._cache.FirstAssaultDelay = first_assault_delay_t
end