-- Can't optimize it further because I can't use GroupAIStateBase functions on client
local BAI = BAI
BAI._cache.AssaultTime = {}
function BAI._cache.AssaultTime:get_difficulty_dependent_value(tweak_values)
    return math.lerp(tweak_values[BAI._cache.AssaultTime.difficulty_point_index], tweak_values[BAI._cache.AssaultTime.difficulty_point_index + 1], BAI._cache.AssaultTime.difficulty_ramp)
end

local function calculate_difficulty_ratio()
    local ramp = tweak_data.group_ai.difficulty_curve_points
    local diff = BAI._cache.AssaultTime.difficulty
    local i = 1

    while (ramp[i] or 1) < diff do
        i = i + 1
    end

    BAI._cache.AssaultTime.difficulty_point_index = i
    BAI._cache.AssaultTime.difficulty_ramp = (diff - (ramp[i - 1] or 0)) / ((ramp[i] or 1) - (ramp[i - 1] or 0))
end

local function get_balancing_multiplier(balance_multipliers)
    local nr_players = 0

    for _, u_data in pairs(managers.groupai:state():all_player_criminals()) do
        if not u_data.status then
            nr_players = nr_players + 1
        end
    end

    local nr_ai = 0

    for _, u_data in pairs(managers.groupai:state():all_AI_criminals()) do
        if not u_data.status then
            nr_ai = nr_ai + 1
        end
    end

    nr_players = nr_players == 1 and nr_players + math.max(0, nr_ai - 1) or nr_players + nr_ai
    nr_players = math.clamp(nr_players, 1, 4)

    return balance_multipliers[nr_players]
end

function BAI:CalculateSpawnsFromDiff()
    return self._cache.AssaultTime:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.force_pool) * get_balancing_multiplier(tweak_data.group_ai.besiege.assault.force_pool_balance_mul)
end

function BAI:CalculateSustainFromDiff()
    return math.lerp(self._cache.AssaultTime:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_min), self._cache.AssaultTime:get_difficulty_dependent_value(tweak_data.group_ai.besiege.assault.sustain_duration_max), math.random()) * get_balancing_multiplier(tweak_data.group_ai.besiege.assault.sustain_duration_balance_mul)
end

function BAI:CalculateSkirmishTime() -- Holdout does not change in Vanilla sustain depending on diff, no need to call BAI:CalculateSustainFromDiff()
    local skirmish_tweak = tweak_data.group_ai.skirmish.assault
    local sustain = skirmish_tweak.sustain_duration_max[1]
    return (skirmish_tweak.build_duration + sustain + skirmish_tweak.fade_duration), sustain
end

function BAI:CalculateAssaultTime() -- To get sustain duration, call function BAI:CalculateSustainFromDiff()
    local assault_tweak = tweak_data.group_ai.besiege.assault
    return assault_tweak.build_duration + assault_tweak.fade_duration
end

function BAI:TryToCorrectTheDiff(level_id) -- Returns diff for heist in which I'm definitely sure about; more info: Mission Scripts from Frankelstner on Bitbucket
    -- Hoxton Breakout Day 1, Safe House Raid, Alaskan Deal
    if self:IsOr(level_id, "hox_1", "chill_combat", "wwh") then
        self._cache.AssaultTime.difficulty = 1
    else
        self._cache.AssaultTime.difficulty = 0.5 -- 0.5 (50%) if playing other heists
    end
    BAI:AddEvents({BAI.EventList.AssaultStateChange, BAI.EventList.AssaultStateChangeOverride}, function(state, ...)
        if state == "anticipation" then
            BAI._cache.client_break_time_left = TimerManager:game():time() + (BAI._cache.is_skirmish and 15 or 30)
        end
    end, nil, 98)
    BAI:AddEvent(BAI.EventList.AssaultEnd, function()
        BAI:SetBreakTimer()
    end, nil, 98)
end

function BAI:CalculateDifficultyRatio()
    calculate_difficulty_ratio()
end

function BAI:SetTimer()
    self:CalculateDifficultyRatio()
    self._cache.client_spawns_left = BAI:CalculateSpawnsFromDiff()
    local sustain
    if self._cache.is_skirmish then
        local value1, value2 = BAI:CalculateSkirmishTime()
        self._cache.client_time_left = TimerManager:game():time() + value1
        sustain = value2
    else
        sustain = BAI:CalculateSustainFromDiff()
        self._cache.client_time_left = TimerManager:game():time() + BAI:CalculateAssaultTime() + sustain
        if self._cache.MutatorAssaultExtender then
            self._cache.client_time_left = self._cache.client_time_left + (sustain / 2)
        end
    end
    if not self.CompatibleHost then
        local tweak = tweak_data.group_ai[self._cache.is_skirmish and "skirmish" or "besiege"].assault
        BAI:DelayCall("BAI_AssaultStateChange_Sustain", tweak.build_duration, function()
            BAI:UpdateAssaultState("sustain")
        end)
        BAI:DelayCall("BAI_AssaultStateChange_Fade", tweak.build_duration + sustain, function()
            BAI:UpdateAssaultState("fade")
        end)
    end
end

function BAI:CalculateRemainingBreakTime()
    local tweak = tweak_data.group_ai[self._cache.is_skirmish and "skirmish" or "besiege"].assault
    local hostage_delay = tweak.hostage_hesitation_delay or { 0, 0, 0 }
    local anticipation = self._cache.is_skirmish and 15 or 30
    local number_of_hostages = managers.groupai:state()._hostage_headcount or 0
    local delay = self._cache.AssaultTime:get_difficulty_dependent_value(tweak.delay)
    local time = TimerManager:game():time() + delay + anticipation + (2 * math.random()) -- 2 (random) seconds correction
    if number_of_hostages > 0 then
        time = time + self._cache.AssaultTime:get_difficulty_dependent_value(hostage_delay)
    end
    self._cache.client_break_time_left = time
end

function BAI:SetBreakTimer()
    self:CalculateDifficultyRatio()
    self:CalculateRemainingBreakTime()
    if self._cache.FirstAssaultDelay then
        self._cache.client_break_time_left = self._cache.client_break_time_left + self._cache.FirstAssaultDelay
        self._cache.FirstAssaultDelay = nil
    end
end

local _f_on_executed = ElementDifficulty.client_on_executed
function ElementDifficulty:client_on_executed(...)
    _f_on_executed(self, ...)
    BAI._cache.AssaultTime.difficulty = self._values.difficulty
end