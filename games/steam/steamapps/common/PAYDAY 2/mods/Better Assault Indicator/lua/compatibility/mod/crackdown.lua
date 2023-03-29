local skirmish = BAI._cache.is_skirmish
local gai_state = managers.groupai:state()

local function GetSkirmishForcePool(assault_number)
    local n
    assault_number = assault_number or 0
    if assault_number == 1 then
        n = BAI._cache:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool_skm1)
    elseif assault_number == 2 then
        n = BAI._cache:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool_skm2)
    elseif assault_number == 3 then
        n = BAI._cache:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool_skm3)
    elseif assault_number == 4 then
        n = BAI._cache:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool_skm4)
    elseif assault_number == 5 then
        n = BAI._cache:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool_skm5)
    elseif assault_number == 6 then
        n = BAI._cache:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool_skm6)
    elseif assault_number >= 7 then
        n = BAI._cache:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool_skm7)
    else
        n = BAI._cache:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool_skm1)
    end
    return n
end

local _f_CalculateSpawnsFromDiff = BAI.CalculateSpawnsFromDiff
function BAI:CalculateSpawnsFromDiff()
    return skirmish and GetSkirmishForcePool(managers.hud._hud_assault_corner._wave_number) or _f_CalculateSpawnsFromDiff(self)
end

local _f_CalculateSpawnsLeft = LocalizationManager.CalculateSpawnsLeft
function LocalizationManager:CalculateSpawnsLeft()
    return skirmish and (gai_state and gai_state._task_data.assault and
    gai_state._task_data.assault.active and GetSkirmishForcePool(gai_state._assault_number) or 0) or _f_CalculateSpawnsLeft(self)
end