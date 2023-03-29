local BAI = BAI
local tweak, gai_state, assault_data, get_value, get_mult
if BAI.IsHost then
    tweak = tweak_data.group_ai.besiege.assault
    if BAI._cache.is_skirmish then
        tweak = tweak_data.group_ai.skirmish.assault
    end
    gai_state = managers.groupai:state()
    assault_data = gai_state and gai_state._task_data.assault
    get_value = gai_state._get_difficulty_dependent_value or function() return 0 end
    get_mult = gai_state._get_balancing_multiplier or function() return 0 end
end
local crimespree = BAI._cache.is_crimespree
local assault_extender = false

function LocalizationManager:CSAE_Activate()
    assault_extender = true
end

local _f_CalculateSpawnsLeft = LocalizationManager.CalculateSpawnsLeft
function LocalizationManager:CalculateSpawnsLeft()
    local spawns = _f_CalculateSpawnsLeft(self)
    return gai_state._assault_number <= 2 and (spawns * 0.75) or spawns
end

function LocalizationManager:CalculateTimeLeftNoFormat(return_value)
    if tweak and gai_state and assault_data and assault_data.active then
        local assault_number_sustain_t_mul
        if gai_state._assault_number <= 2 then
            assault_number_sustain_t_mul = 0.75
        else
            assault_number_sustain_t_mul = 1
        end

        local add
        local time_left = assault_data.phase_end_t - gai_state._t
        if crimespree or assault_extender then
            local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), math.random()) * get_mult(gai_state, tweak.sustain_duration_balance_mul) * assault_number_sustain_t_mul
            add = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", sustain_duration) - sustain_duration
            if add == 0 and gai_state._assault_number == 1 and assault_data.phase == "build" then
                add = sustain_duration / 2 * assault_number_sustain_t_mul
            end
        end
        if assault_data.phase == "build" then
            local sustain_duration = math.lerp(get_value(gai_state, tweak.sustain_duration_min), get_value(gai_state, tweak.sustain_duration_max), math.random()) * get_mult(gai_state, tweak.sustain_duration_balance_mul) * assault_number_sustain_t_mul
            time_left = time_left + sustain_duration + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        elseif assault_data.phase == "sustain" then
            time_left = time_left + tweak.fade_duration
            if add then
                time_left = time_left + add
            end
        end
        return time_left
    end
    return return_value or -1
end

function BAI:GetAssaultTime(sender)
    if self.IsHost and self._cache.AssaultType == self.Enum.AssaultType.Normal and sender then
        local l_tweak = tweak_data.group_ai[self._cache.is_skirmish and "skirmish" or "besiege"].assault
        local l_gai_state = managers.groupai:state()
        local l_assault_data = l_gai_state and l_gai_state._task_data.assault
        local l_get_value = l_gai_state._get_difficulty_dependent_value or function() return 0 end
        local l_get_mult = l_gai_state._get_balancing_multiplier or function() return 0 end

        if not (l_tweak and l_gai_state and l_assault_data and l_assault_data.active) then
            return
        end

        local sustain_multiplier = 1
        if gai_state._wave_number <= 2 then
            sustain_multiplier = 0.75
        end

        local time = l_assault_data.phase_end_t - l_gai_state._t
        local add
        if self._cache.is_crimespree or self._cache.MutatorAssaultExtender then
            local sustain_duration = math.lerp(l_get_value(l_gai_state, l_tweak.sustain_duration_min), l_get_value(l_gai_state, l_tweak.sustain_duration_max), 0.5) * l_get_mult(l_gai_state, l_tweak.sustain_duration_balance_mul) * sustain_multiplier
            add = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", sustain_duration) - sustain_duration
            if add == 0 and l_gai_state._assault_number == 1 and l_assault_data.phase == "build" then
                add = sustain_duration / 2
            end
        end
        if assault_data.phase == "build" then
            local sustain_duration = math.lerp(l_get_value(l_gai_state, l_tweak.sustain_duration_min), l_get_value(l_gai_state, l_tweak.sustain_duration_max), 0.5) * l_get_mult(l_gai_state, l_tweak.sustain_duration_balance_mul) * sustain_multiplier
            time = time + sustain_duration + l_tweak.fade_duration
            if add then
                time = time + add
            end
        elseif assault_data.phase == "sustain" then
            time = time + l_tweak.fade_duration
            if add then
                time = time + add
            end
        end
        LuaNetworking:SendToPeer(sender, self.AAI_SyncMessage, time)
    end
end

if BAI.IsHost then
    return
end
local _f_CalculateSustainFromDiff = BAI.CalculateSustainFromDiff
function BAI:CalculateSustainFromDiff()
    local sustain = _f_CalculateSustainFromDiff(self)
    local sustain_multiplier = 1
    if managers.hud._hud_assault_corner._wave_number <= 2 then
        sustain_multiplier = 0.75
    end
    return sustain * sustain_multiplier, sustain_multiplier
end

local _f_CalculateSpawnsFromDiff = BAI.CalculateSpawnsFromDiff
function BAI:CalculateSpawnsFromDiff()
    local spawns = _f_CalculateSpawnsFromDiff(self)
    return managers.hud._hud_assault_corner._wave_number <= 2 and (spawns * 0.75) or spawns
end

function BAI:SetTimer()
    BAI:CalculateDifficultyRatio()
    self._cache.client_spawns_left = BAI:CalculateSpawnsFromDiff()
    local sustain
    if self._cache.is_skirmish then
        local value1, value2 = BAI:CalculateSkirmishTime()
        self._cache.client_time_left = TimerManager:game():time() + value1
        sustain = value2
    else
        local sustain_multiplier
        sustain, sustain_multiplier = BAI:CalculateSustainFromDiff()
        self._cache.client_time_left = TimerManager:game():time() + BAI:CalculateAssaultTime() + sustain
        if self._cache.MutatorAssaultExtender then
            self._cache.client_time_left = self._cache.client_time_left + (sustain / 2 * sustain_multiplier)
        end
    end
    if not self.CompatibleHost then
        local td = tweak_data.group_ai[self._cache.is_skirmish and "skirmish" or "besiege"].assault
        BAI:DelayCall("BAI_AssaultStateChange_Sustain", td.build_duration, function()
            BAI:UpdateAssaultState("sustain")
        end)
        BAI:DelayCall("BAI_AssaultStateChange_Fade", td.build_duration + sustain, function()
            BAI:UpdateAssaultState("fade")
        end)
    end
end